package org.ironfoxoss.ironfox.updater

import android.content.pm.PackageInstaller
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

/** Why an update did not install. */
enum class InstallFailure { BLOCKED, INCOMPATIBLE, CONFLICT, INVALID, STORAGE, ABORTED }

/** Maps [PackageInstaller] status codes to [InstallFailure]. */
object InstallFailureMapper {

    /** Returns the failure for a `STATUS_FAILURE*` code; unknown codes count as [InstallFailure.ABORTED]. */
    fun fromStatus(status: Int): InstallFailure = when (status) {
        PackageInstaller.STATUS_FAILURE_BLOCKED -> InstallFailure.BLOCKED
        PackageInstaller.STATUS_FAILURE_INCOMPATIBLE -> InstallFailure.INCOMPATIBLE
        PackageInstaller.STATUS_FAILURE_CONFLICT -> InstallFailure.CONFLICT
        PackageInstaller.STATUS_FAILURE_INVALID -> InstallFailure.INVALID
        PackageInstaller.STATUS_FAILURE_STORAGE -> InstallFailure.STORAGE
        else -> InstallFailure.ABORTED
    }
}

/** Carries install failures from the status receiver to whichever screen is showing. */
object InstallEvents {
    private val latestFailure = MutableStateFlow<InstallFailure?>(null)

    /** The most recent failure that has not been consumed. */
    val failures: StateFlow<InstallFailure?> = latestFailure

    /** Records [failure] for the UI to show. */
    fun publish(failure: InstallFailure) {
        latestFailure.value = failure
    }

    /** Marks the current failure as handled. */
    fun consume() {
        latestFailure.value = null
    }
}
