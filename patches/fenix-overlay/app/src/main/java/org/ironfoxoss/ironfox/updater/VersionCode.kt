package org.ironfoxoss.ironfox.updater

/** Decodes and compares IronFox version codes. */
object VersionCode {
    private const val VARIANT_MASK = 0b111L
    private const val BUILD_SHIFT = 3

    /** Returns the [Variant] encoded in the low bits of [versionCode]. */
    fun variantOf(versionCode: Long): Variant {
        val bits = (versionCode and VARIANT_MASK).toInt()
        return requireNotNull(Variant.entries.firstOrNull { it.lowBits == bits }) {
            "Version code $versionCode has no known variant"
        }
    }

    /** Returns whether [feed] is a strictly newer build than [installed], ignoring the variant bits. */
    fun isNewerBuild(feed: Long, installed: Long): Boolean =
        (feed shr BUILD_SHIFT) > (installed shr BUILD_SHIFT)
}
