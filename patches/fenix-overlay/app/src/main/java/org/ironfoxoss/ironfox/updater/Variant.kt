package org.ironfoxoss.ironfox.updater

/**
 * An IronFox APK flavour, identified by the low bits of its version code.
 *
 * @property feedKey The key of this variant in the update feed.
 * @property lowBits The low three bits of a version code built for this variant.
 */
enum class Variant(val feedKey: String, val lowBits: Int) {
  ARMEABI_V7A("armeabi-v7a", 0b000),
  ARM64_V8A("arm64-v8a", 0b010),
  X86_64("x86_64", 0b110),
  UNIVERSAL("universal", 0b111),
}
