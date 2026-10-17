package org.ironfoxoss.ironfox.updater

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.pm.PackageInfoCompat
import java.io.File

/** Reads the install source of this app from the [PackageManager]. */
class PackageInstallSourceReader(
    private val packageManager: PackageManager,
    private val packageName: String,
) : InstallSourceReader {

    override val installingPackage: String?
        get() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            packageManager.getInstallSourceInfo(packageName).installingPackageName
        } else {
            @Suppress("DEPRECATION")
            packageManager.getInstallerPackageName(packageName)
        }

    override val updateOwnerPackage: String?
        get() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            packageManager.getInstallSourceInfo(packageName).updateOwnerPackageName
        } else {
            null
        }
}

/** Returns the [InstallerGate] for the running app. */
fun createInstallerGate(context: Context): InstallerGate =
    InstallerGate(PackageInstallSourceReader(context.packageManager, context.packageName), context.packageName)

/** Reads APK identity fields with [PackageManager.getPackageArchiveInfo]. */
class PackageArchiveInspector(private val packageManager: PackageManager) : ArchiveInspector {

    override fun packageNameOf(apk: File): String? = archiveInfo(apk)?.packageName

    override fun versionCodeOf(apk: File): Long? = archiveInfo(apk)?.let(PackageInfoCompat::getLongVersionCode)

    private fun archiveInfo(apk: File) = packageManager.getPackageArchiveInfo(apk.absolutePath, 0)
}
