const DEFAULT_SETTINGS = {
  enabled: true,
  mode: "cursor", // "cursor" | "spatial"
  speed: 8,       // 1 - 20 range
  keyUp: "ArrowUp",
  keyLeft: "ArrowLeft",
  keyDown: "ArrowDown",
  keyRight: "ArrowRight",
  keyClick: "",
  keyToggleMode: "KeyQ",
  keySpeedBoost: "Shift",
  keyRightClick: "KeyE",
  keyMiddleClick: "KeyR",
  keyBack: "",
  keyForward: "",
  ignoreInputs: true,
  cursorSize: 18,
  cursorColor: "#38bdf8",
  cursorBorderColor: "#ffffff",
  cursorGlow: true,
  cursorOpacity: 0.8
};

// Set default settings on install
chrome.runtime.onInstalled.addListener(() => {
  chrome.storage.local.get(Object.keys(DEFAULT_SETTINGS), (result) => {
    const initSettings = {};
    for (const key in DEFAULT_SETTINGS) {
      if (result[key] === undefined) {
        initSettings[key] = DEFAULT_SETTINGS[key];
      }
    }
    if (Object.keys(initSettings).length > 0) {
      chrome.storage.local.set(initSettings, () => {
        console.log("Virtual Cursor: Defaults initialized", initSettings);
      });
    }
  });
});
