/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package org.ironfoxoss.ironfox.updater

import android.content.Context
import androidx.core.content.pm.PackageInfoCompat
import java.util.concurrent.atomic.AtomicBoolean
import java.io.File
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.fetch.Client
import org.mozilla.fenix.BuildConfig
import org.mozilla.fenix.ext.components

/**
 * Coordinates checking, downloading and installing updates for the UI.
 *
 * Methods that read Gecko preferences must be called from the main thread.
 */
class UpdateController private constructor(
    context: Context,
    private val engine: Engine,
    private val client: Client,
) {
    private val appContext = context.applicationContext
    private val packageManager = appContext.packageManager

    /** The persisted updater state. */
    val settings = UpdaterSettings(appContext)

    /** Decides whether the updater may run for the way IronFox was installed. */
    val gate = createInstallerGate(appContext)

    /** Commits verified APKs to the system installer. */
    val installer = ApkInstaller(appContext) { settings.allowOtherSources }

    /** The newest offer seen by a check in this process, if it is newer than the installed build. */
    @Volatile
    var availableOffer: UpdateOffer? = null
        private set

    /** The offer the user last asked to install, kept so a failed install can be retried. */
    @Volatile
    var lastRequestedOffer: UpdateOffer? = null

    private val installedVersionCode: Long
        get() = PackageInfoCompat.getLongVersionCode(packageManager.getPackageInfo(appContext.packageName, 0))

    private val updateInProgress = AtomicBoolean(false)

    /** Claims the single update slot; returns false if an update is already downloading or installing. */
    fun beginUpdate(): Boolean = updateInProgress.compareAndSet(false, true)

    /** Releases the slot taken by [beginUpdate]. */
    fun endUpdate() = updateInProgress.set(false)

    /** Returns whether the updater may run given the install source and the user's override. */
    fun isUpdaterAllowed(): Boolean = gate.isAllowed(settings.allowOtherSources)

    /**
     * Checks the feed; an automatic check does nothing unless the updater is enabled, allowed and due.
     *
     * @throws java.io.IOException on network failure.
     * @throws ManifestException if the feed is malformed.
     * @throws SecurityException if the feed leaves the host allowlist.
     */
    suspend fun check(manual: Boolean): CheckResult {
        if (!manual && !isUpdaterAllowed()) return CheckResult.NotDue
        val config = GeckoUpdaterConfig.load(engine)
        val result = withContext(Dispatchers.IO) { newChecker(config).check(manual) }
        availableOffer = when (result) {
            is CheckResult.Available -> result.offer
            is CheckResult.Dismissed -> result.offer
            CheckResult.UpToDate -> null
            CheckResult.NotDue -> availableOffer
        }
        return result
    }

    /**
     * Downloads and verifies the APK for [offer], clearing superseded APKs first.
     *
     * @throws ApkVerificationException if the download does not match the feed.
     */
    suspend fun download(offer: UpdateOffer, onProgress: (Int) -> Unit): File {
        val config = GeckoUpdaterConfig.load(engine)
        return withContext(Dispatchers.IO) {
            val downloader = newDownloader(config)
            downloader.cleanup(installedVersionCode, offer)
            downloader.obtain(offer, VersionCode.variantOf(installedVersionCode), onProgress)
        }
    }

    /** Hands [apk] to the system installer. */
    suspend fun install(apk: File) = withContext(Dispatchers.IO) { installer.install(apk) }

    /** Abandons install sessions left open by a previous run and deletes stale cached APKs. */
    suspend fun cleanUpAfterStartup() {
        val config = GeckoUpdaterConfig.load(engine)
        withContext(Dispatchers.IO) {
            runCatching { ApkInstaller.abandonLeftoverSessions(appContext) }
            runCatching { newDownloader(config).cleanup(installedVersionCode, keep = null) }
        }
    }

    private fun newChecker(config: UpdaterConfig) = UpdateChecker(
        fetcher = fetcherFor(config),
        config = config,
        store = settings,
        packageName = BuildConfig.APPLICATION_ID,
        installedVersionCode = installedVersionCode,
        clock = System::currentTimeMillis,
    )

    private fun newDownloader(config: UpdaterConfig) = ApkDownloader(
        fetcher = fetcherFor(config),
        cacheDir = appContext.cacheDir,
        verifier = ApkVerifier(PackageArchiveInspector(packageManager), BuildConfig.APPLICATION_ID),
    )

    private fun fetcherFor(config: UpdaterConfig) =
        AllowlistedFetcher(client, HostAllowlist(config.allowedHosts, config.allowInsecureHttp))

    companion object {
        @Volatile
        private var instance: UpdateController? = null

        /** Returns the process-wide controller. */
        fun from(context: Context): UpdateController = instance ?: synchronized(this) {
            instance ?: UpdateController(
                context,
                context.components.core.engine,
                context.components.core.client,
            ).also { instance = it }
        }
    }
}
