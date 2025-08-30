/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components.metrics

import android.content.Context
import android.content.pm.PackageManager

class FirstSessionPing(
    private val context: Context,
) {
    private fun installSourcePackageForBuildMinR(
        packageManager: PackageManager,
        packageName: String,
    ) = null

    private fun installSourcePackageForBuildMaxQ(
        packageManager: PackageManager,
        packageName: String,
    ) = null

    fun checkAndSend() {
        return
    }
}
