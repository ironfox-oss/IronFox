/* Hi, I'm a stub. ;) */

/* Inspired by https://github.com/ghostery/user-agent-android/blob/b634c81054bfdf378ef1c6668053cb043995a6a1/patches/0011-Disabling-Telemetry-CrashReports.patch (MPL-2.0) */

package org.ironfoxoss.ironfox

import mozilla.components.lib.crash.Crash
import mozilla.components.lib.crash.service.CrashReporterService
import mozilla.components.concept.base.crash.Breadcrumb

class NoopCrashService : CrashReporterService {
    override val id: String = ""

    override val name: String = ""

    override fun createCrashReportUrl(identifier: String): String? = null

    override fun report(throwable: Throwable, breadcrumbs: ArrayList<Breadcrumb>): String? = null

    override fun report(crash: Crash.NativeCodeCrash): String? = null

    override fun report(crash: Crash.UncaughtExceptionCrash): String? = null
}
