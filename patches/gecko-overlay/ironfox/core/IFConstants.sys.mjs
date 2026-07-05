#filter substitution

/**
 * IronFox Constants
 */
export const IFConstants = Object.freeze({
  IRONFOX_APP_NAME:                 "@IRONFOX_APP_NAME@",
  IRONFOX_APP_NAME_PRETTY:          "@IRONFOX_APP_NAME_PRETTY@",
  IRONFOX_BUGS_URL:                 "@IRONFOX_BUGS_URL@",
  IRONFOX_CHANNEL:                  "@IRONFOX_CHANNEL@",
  IRONFOX_DEFAULT_DOH_URL:          "@IRONFOX_DEFAULT_DOH_URL@",
  IRONFOX_DEFAULT_UBO_ASSETS_URL:   "@IRONFOX_DEFAULT_UBO_ASSETS_URL@",
  IRONFOX_FAQ_URL:                  "@IRONFOX_FAQ_URL@",
  IRONFOX_RELEASES_URL:             "@IRONFOX_RELEASES_URL@",
  IRONFOX_REPO_GIT_URL:             "@IRONFOX_REPO_GIT_URL@",
  IRONFOX_REPO_URL:                 "@IRONFOX_REPO_URL@",
  IRONFOX_URL:                      "@IRONFOX_URL@",
  IRONFOX_VERSION:                  "@IRONFOX_VERSION@",

  IRONFOX_RELEASE:
#ifdef IRONFOX_RELEASE
  true,
#else
  false,
#endif

  IRONFOX_NIGHTLY:
#ifdef IRONFOX_NIGHTLY
  true,
#else
  false,
#endif
});
