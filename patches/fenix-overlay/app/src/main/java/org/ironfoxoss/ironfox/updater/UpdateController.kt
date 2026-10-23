package org.ironfoxoss.ironfox.updater

import android.content.Context
import android.content.Intent
import androidx.core.content.pm.PackageInfoCompat
import java.io.File
import java.net.URI
import java.util.concurrent.atomic.AtomicBoolean
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mozilla.components.concept.fetch.Client
import mozilla.components.support.base.log.logger.Logger
import org.ironfoxoss.core.IFConstants
import org.mozilla.fenix.ext.components

/** Coordinates checking, downloading and installing updates for the UI. */
class UpdateController private constructor(
  context: Context,
  private val client: Client,
) {
  private val appContext = context.applicationContext
  private val packageManager = appContext.packageManager
  private val installSource: InstallSource

  /** The persisted updater settings and state. */
  val settings = appContext.components.settings.ironfox

  /** Commits verified APKs to the system installer. */
  val installer = ApkInstaller(appContext)

  /** The newest offer seen by a check in this process, if it is newer than the installed build. */
  @Volatile
  var availableOffer: UpdateOffer? = null
    private set

  /** The offer the user last asked to install, kept so a failed install can be retried. */
  @Volatile
  var lastRequestedOffer: UpdateOffer? = null

  private val installedVersionCode: Long
    get() = PackageInfoCompat.getLongVersionCode(packageManager.getPackageInfo(IFConstants.IRONFOX_APP_ID, 0))

  private val logger = Logger("UpdateController")
  private val updateInProgress = AtomicBoolean(false)
  private val checkInProgress = AtomicBoolean(false)

  init {
    installSource = InstallSource(appContext, settings)
  }

  /** The known store IronFox was installed from, if any. */
  val rememberedStore: KnownStore?
    get() = installSource.rememberedStore

  /** The store the Update button should open: the remembered store, unless the user chose direct downloads. */
  val activeStore: KnownStore?
    get() = rememberedStore.takeUnless { settings.updaterDirectDownloads }

  /** Whether IronFox downloads an update as soon as it finds one: the user wants it and IronFox downloads APKs itself. */
  val autoDownloadActive: Boolean
    get() = settings.updaterAutoDownload && activeStore == null

  /** Returns whether the APK for [offer] was already downloaded and verified. */
  fun isDownloaded(offer: UpdateOffer): Boolean = newDownloader().isCached(offer)

  /**
   * Downloads [offer] ahead of the user's request if automatic downloads are active; never throws on failure.
   *
   * @return Whether the verified APK is ready to install.
   */
  suspend fun downloadAhead(offer: UpdateOffer): Boolean {
    if (!autoDownloadActive || !beginUpdate()) return false
    return try {
      download(offer) {}
      true
    } catch (e: CancellationException) {
      throw e
    } catch (e: Exception) {
      logger.warn("Automatic update download failed", e)
      false
    } finally {
      endUpdate()
    }
  }

  /** Remembers the installing store, if it is a known one. Cheap and local; call before checking. */
  fun rememberInstaller() = installSource.rememberInstaller()

  /** Returns an intent that opens [store], or null if it is not installed. */
  fun launchIntentFor(store: KnownStore): Intent? = installSource.launchIntentFor(store)

  /** Claims the single update slot; returns false if an update is already downloading or installing. */
  fun beginUpdate(): Boolean = updateInProgress.compareAndSet(false, true)

  /** Releases the slot taken by [beginUpdate]. */
  fun endUpdate() = updateInProgress.set(false)

  /** Returns whether an update is downloading or installing. */
  val isUpdating: Boolean
    get() = updateInProgress.get()

  /** Claims the single check slot; returns false if a check is already running. */
  fun beginCheck(): Boolean = checkInProgress.compareAndSet(false, true)

  /** Releases the slot taken by [beginCheck]. */
  fun endCheck() = checkInProgress.set(false)

  /**
   * Checks the feed; an automatic check does nothing unless the updater is enabled and due.
   *
   * @throws java.io.IOException on network failure.
   * @throws ManifestException if the feed is malformed.
   * @throws SecurityException if the feed leaves the host allowlist.
   */
  suspend fun check(manual: Boolean): CheckResult {
    val result = try {
      withContext(Dispatchers.IO) { newChecker().check(manual) }
    } catch (e: CancellationException) {
      throw e
    } catch (e: Exception) {
      settings.updaterLastFailureMillis = System.currentTimeMillis()
      throw e
    }
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
  suspend fun download(offer: UpdateOffer, onProgress: (Int) -> Unit): File = withContext(Dispatchers.IO) {
    val downloader = newDownloader()
    downloader.cleanup(installedVersionCode, offer)
    downloader.obtain(offer, VersionCode.variantOf(installedVersionCode), onProgress)
  }

  /** Hands [apk] to the system installer. */
  suspend fun install(apk: File) = withContext(Dispatchers.IO) { installer.install(apk) }

  /** Abandons install sessions left open by a previous run and deletes stale cached APKs. */
  suspend fun cleanUpAfterStartup() {
    withContext(Dispatchers.IO) {
      runCatching { ApkInstaller.abandonLeftoverSessions(appContext) }
      runCatching { newDownloader().cleanup(installedVersionCode, keep = null) }
    }
  }

  private fun newChecker() = UpdateChecker(
    fetcher = newFetcher(),
    feedUrl = IFConstants.IRONFOX_UPDATE_MANIFEST_URL,
    settings = settings,
    packageName = IFConstants.IRONFOX_APP_ID,
    installedVersionCode = installedVersionCode,
    clock = System::currentTimeMillis,
  )

  private fun newDownloader() = ApkDownloader(
    fetcher = newFetcher(),
    cacheDir = appContext.cacheDir,
    verifier = ApkVerifier(PackageArchiveInspector(packageManager), IFConstants.IRONFOX_APP_ID),
  )

  private fun newFetcher(): AllowlistedFetcher {
    val host = URI(IFConstants.IRONFOX_UPDATE_MANIFEST_URL).host.orEmpty()
    val allowInsecureHttp = IFConstants.IRONFOX_NIGHTLY && settings.updaterAllowInsecureHttp
    return AllowlistedFetcher(client, HostAllowlist(host, allowInsecureHttp))
  }

  companion object {
    @Volatile
    private var instance: UpdateController? = null

    /** Returns the process-wide controller. */
    fun from(context: Context): UpdateController = instance ?: synchronized(this) {
      instance ?: UpdateController(context, context.components.core.client).also { instance = it }
    }
  }
}
