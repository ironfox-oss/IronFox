// Inspired by https://searchfox.org/firefox-main/source/toolkit/components/normandy/content/AboutPages.sys.mjs

import { XPCOMUtils } from "resource://gre/modules/XPCOMUtils.sys.mjs";

const lazy = {};

/**
 * Class for managing about: pages provided by IronFox.
 *
 * @implements nsIFactory
 * @implements nsIAboutModule
 */
class AboutPage {
  constructor({ chromeUrl, aboutHost, classID, description, uriFlags }) {
    this.chromeUrl = chromeUrl;
    this.aboutHost = aboutHost;
    this.classID = Components.ID(classID);
    this.description = description;
    this.uriFlags = uriFlags;
  }

  getURIFlags() {
    return this.uriFlags;
  }

  newChannel(uri, loadInfo) {
    const newURI = Services.io.newURI(this.chromeUrl);
    const channel = Services.io.newChannelFromURIWithLoadInfo(newURI, loadInfo);
    channel.originalURI = uri;

    if (this.uriFlags & Ci.nsIAboutModule.URI_SAFE_FOR_UNTRUSTED_CONTENT) {
      const principal = Services.scriptSecurityManager.createContentPrincipal(
        uri,
        {}
      );
      channel.owner = principal;
    }
    return channel;
  }
}
AboutPage.prototype.QueryInterface = ChromeUtils.generateQI(["nsIAboutModule"]);

/**
 * The module exported by this file.
 */
export let IronFoxAboutPages = {};

ChromeUtils.defineLazyGetter(IronFoxAboutPages, "aboutAttribution", () => {
  const aboutAttribution = new AboutPage({
    chromeUrl: "chrome://ironfox/content/attribution.html",
    aboutHost: "attribution",
    classID: "{4c85223f-3c1b-475a-8527-dc8ef69ca822}",
    description: "about:attribution",
    uriFlags:
      Ci.nsIAboutModule.URI_SAFE_FOR_UNTRUSTED_CONTENT,
  });
  return aboutAttribution;
});

ChromeUtils.defineLazyGetter(IronFoxAboutPages, "aboutIronFox", () => {
  const aboutIronFox = new AboutPage({
    chromeUrl: "chrome://ironfox/content/ironfox.html",
    aboutHost: "ironfox",
    classID: "{a88bc9f2-3cad-4cbd-b97d-3036db4740ff}",
    description: "about:ironfox",
    uriFlags:
      Ci.nsIAboutModule.URI_SAFE_FOR_UNTRUSTED_CONTENT,
  });
  return aboutIronFox;
});

ChromeUtils.defineLazyGetter(IronFoxAboutPages, "aboutPolicies", () => {
  const aboutPolicies = new AboutPage({
    chromeUrl: "chrome://browser/content/policies/aboutPolicies.html",
    aboutHost: "policies",
    classID: "{b3ac3a21-fb4b-4013-9bcb-bbb4ae1ea861}",
    description: "about:policies",
    uriFlags:
      Ci.nsIAboutModule.ALLOW_SCRIPT |
      Ci.nsIAboutModule.IS_SECURE_CHROME_UI,
  });
  return aboutPolicies;
});

ChromeUtils.defineLazyGetter(IronFoxAboutPages, "aboutRobots", () => {
  const aboutRobots = new AboutPage({
    chromeUrl: "chrome://browser/content/aboutRobots.xhtml",
    aboutHost: "robots",
    classID: "{057bb874-aabf-4b9a-a43e-3440c3e4bfa2}",
    description: "about:robots",
    uriFlags:
      Ci.nsIAboutModule.ALLOW_SCRIPT |
      Ci.nsIAboutModule.URI_SAFE_FOR_UNTRUSTED_CONTENT,
  });
  return aboutRobots;
});

export function AboutAttribution() {
  return IronFoxAboutPages.aboutAttribution;
}

export function AboutIronFox() {
  return IronFoxAboutPages.aboutIronFox;
}

export function AboutPolicies() {
  return IronFoxAboutPages.aboutPolicies;
}

export function AboutRobots() {
  return IronFoxAboutPages.aboutRobots;
}
