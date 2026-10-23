package org.ironfoxoss.ironfox.updater

import android.content.pm.PackageManager
import androidx.core.content.pm.PackageInfoCompat
import java.io.File

/** Reads APK identity fields with [PackageManager.getPackageArchiveInfo]. */
class PackageArchiveInspector(private val packageManager: PackageManager) : ArchiveInspector {

    override fun packageNameOf(apk: File): String? = archiveInfo(apk)?.packageName

    override fun versionCodeOf(apk: File): Long? = archiveInfo(apk)?.let(PackageInfoCompat::getLongVersionCode)

    private fun archiveInfo(apk: File) = packageManager.getPackageArchiveInfo(apk.absolutePath, 0)
}
