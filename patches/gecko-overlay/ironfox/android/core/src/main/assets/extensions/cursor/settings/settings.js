document.addEventListener("DOMContentLoaded", () => {
  // UI Elements
  const enabledToggle = document.getElementById("enabled-toggle");
  const ignoreInputsToggle = document.getElementById("ignore-inputs-toggle");
  const speedRange = document.getElementById("speed-range");
  const speedValue = document.getElementById("speed-value");
  
  const modeTabs = document.querySelectorAll(".mode-tab");
  const cursorSettingsGroup = document.getElementById("cursor-settings-group");
  
  const cursorSizeInput = document.getElementById("cursor-size");
  const cursorSizeValue = document.getElementById("cursor-size-value");
  
  const cursorOpacityInput = document.getElementById("cursor-opacity");
  const cursorOpacityValue = document.getElementById("cursor-opacity-value");
  
  const colorDots = document.querySelectorAll(".color-dot");
  const glowToggle = document.getElementById("glow-toggle");

  // Key Bindings elements
  const keycapButtons = {
    keyUp: document.getElementById("keycap-up"),
    keyLeft: document.getElementById("keycap-left"),
    keyDown: document.getElementById("keycap-down"),
    keyRight: document.getElementById("keycap-right"),
    keyClick: document.getElementById("keycap-click"),
    keyRightClick: document.getElementById("keycap-right-click"),
    keyMiddleClick: document.getElementById("keycap-middle-click"),
    keyToggleMode: document.getElementById("keycap-toggle-mode"),
    keySpeedBoost: document.getElementById("keycap-speed-boost"),
    keyBack: document.getElementById("keycap-back"),
    keyForward: document.getElementById("keycap-forward")
  };
  const resetKeysBtn = document.getElementById("reset-keys-btn");

  let currentRecordingAction = null;
  let activeRecordingListener = null;

  // Load and apply settings
  const settingsKeys = [
    "enabled", "mode", "speed", "ignoreInputs", 
    "cursorSize", "cursorColor", "cursorBorderColor", "cursorGlow", "cursorOpacity",
    "keyUp", "keyLeft", "keyDown", "keyRight", "keyClick", "keyRightClick", "keyMiddleClick", "keyToggleMode", "keyBack", "keyForward", "keySpeedBoost"
  ];

  chrome.storage.local.get(settingsKeys, (settings) => {
    // 1. Enable Toggle
    enabledToggle.checked = settings.enabled !== false;
    
    // 2. Ignore inputs
    ignoreInputsToggle.checked = settings.ignoreInputs !== false;
    
    // 3. Mode Tabs
    const currentMode = settings.mode || "cursor";
    updateModeTabsUI(currentMode);

    // 4. Speed
    const speed = settings.speed || 8;
    speedRange.value = speed;
    speedValue.textContent = speed;

    // 5. Cursor Size
    const size = settings.cursorSize || 18;
    cursorSizeInput.value = size;
    cursorSizeValue.textContent = size + "px";

    // 6. Cursor Opacity
    const opacity = (settings.cursorOpacity !== undefined) ? Math.round(settings.cursorOpacity * 100) : 80;
    cursorOpacityInput.value = opacity;
    cursorOpacityValue.textContent = opacity + "%";

    // 7. Glow Toggle
    glowToggle.checked = settings.cursorGlow !== false;

    // 8. Color Preset Dots
    const activeColor = settings.cursorColor || "#38bdf8";
    let isPreset = false;
    colorDots.forEach(dot => {
      if (dot.getAttribute("data-color").toLowerCase() === activeColor.toLowerCase()) {
        dot.classList.add("active");
        isPreset = true;
      } else {
        dot.classList.remove("active");
      }
    });

    if (!isPreset && colorDots.length > 0) {
      colorDots[0].classList.add("active");
    }

    // 9. Keycaps Labels
    const keys = {
      keyUp: settings.keyUp || "ArrowUp",
      keyLeft: settings.keyLeft || "ArrowLeft",
      keyDown: settings.keyDown || "ArrowDown",
      keyRight: settings.keyRight || "ArrowRight",
      keyClick: settings.keyClick || "",
      keyRightClick: settings.keyRightClick || "KeyE",
      keyMiddleClick: settings.keyMiddleClick || "KeyR",
      keyToggleMode: settings.keyToggleMode || "KeyQ",
      keySpeedBoost: settings.keySpeedBoost || "Shift",
      keyBack: settings.keyBack || "",
      keyForward: settings.keyForward || ""
    };
    
    for (const action in keycapButtons) {
      if (keycapButtons[action]) {
        keycapButtons[action].textContent = getFriendlyKeyName(keys[action]);
      }
    }
    updateDynamicGuides(keys);

  });

  // Event Listeners

  // Global Enable Toggle
  enabledToggle.addEventListener("change", () => {
    chrome.storage.local.set({ enabled: enabledToggle.checked });
  });

  // Ignore inputs toggle
  ignoreInputsToggle.addEventListener("change", () => {
    chrome.storage.local.set({ ignoreInputs: ignoreInputsToggle.checked });
  });

  // Mode Selection Tabs
  modeTabs.forEach(tab => {
    tab.addEventListener("click", () => {
      const selectedMode = tab.getAttribute("data-mode");
      updateModeTabsUI(selectedMode);
      chrome.storage.local.set({ mode: selectedMode });
    });
  });

  // Speed Slider
  speedRange.addEventListener("input", () => {
    const val = speedRange.value;
    speedValue.textContent = val;
    chrome.storage.local.set({ speed: parseInt(val, 10) });
  });

  // Cursor Size Slider
  cursorSizeInput.addEventListener("input", () => {
    const size = cursorSizeInput.value;
    cursorSizeValue.textContent = size + "px";
    chrome.storage.local.set({ cursorSize: parseInt(size, 10) });
  });

  // Cursor Opacity Slider
  cursorOpacityInput.addEventListener("input", () => {
    const opacityVal = cursorOpacityInput.value;
    cursorOpacityValue.textContent = opacityVal + "%";
    chrome.storage.local.set({ cursorOpacity: parseFloat((opacityVal / 100).toFixed(2)) });
  });

  // Preset Colors
  colorDots.forEach(dot => {
    dot.addEventListener("click", () => {
      colorDots.forEach(d => d.classList.remove("active"));
      dot.classList.add("active");
      
      const selectedColor = dot.getAttribute("data-color");
      chrome.storage.local.set({ cursorColor: selectedColor });
    });
  });

  // Glow Toggle
  glowToggle.addEventListener("change", () => {
    chrome.storage.local.set({ cursorGlow: glowToggle.checked });
  });

  // Keycap Recording Listeners
  for (const action in keycapButtons) {
    const button = keycapButtons[action];
    if (button) {
      button.addEventListener("click", () => {
        startKeyRecording(action, button);
      });
    }
  }

  // Reset Keys Bindings to Default
  if (resetKeysBtn) {
    resetKeysBtn.addEventListener("click", () => {
      cancelRecording();
      
      const defaults = {
        keyUp: "ArrowUp",
        keyLeft: "ArrowLeft",
        keyDown: "ArrowDown",
        keyRight: "ArrowRight",
        keyClick: "",
        keyRightClick: "KeyE",
        keyMiddleClick: "KeyR",
        keyToggleMode: "KeyQ",
        keySpeedBoost: "Shift",
        keyBack: "",
        keyForward: ""
      };

      chrome.storage.local.set(defaults, () => {
        for (const action in keycapButtons) {
          if (keycapButtons[action]) {
            keycapButtons[action].textContent = getFriendlyKeyName(defaults[action]);
          }
        }
        updateDynamicGuides(defaults);
      });
    });
  }

  // Helper functions

  function startKeyRecording(action, button) {
    // If clicking the button that is already recording, cancel it
    if (currentRecordingAction === action) {
      cancelRecording();
      return;
    }

    // Cancel any other running recording
    cancelRecording();

    currentRecordingAction = action;
    button.classList.add("recording");
    button.textContent = "...";

    // Setup temporary window keyboard listener
    activeRecordingListener = (e) => {
      e.preventDefault();
      e.stopPropagation();

      const pressedKey = e.code;

      // Allow canceling with Escape
      if (pressedKey === "Escape") {
        cancelRecording();
        return;
      }

      // Allow clearing optional keys with Backspace or Delete
      let finalKey = pressedKey;
      if (pressedKey === "Backspace" || pressedKey === "Delete") {
        finalKey = "";
      } else if (pressedKey === "ShiftLeft" || pressedKey === "ShiftRight") {
        finalKey = "Shift";
      } else if (pressedKey === "ControlLeft" || pressedKey === "ControlRight") {
        finalKey = "Control";
      } else if (pressedKey === "AltLeft" || pressedKey === "AltRight") {
        finalKey = "Alt";
      }

      // Save bound key
      const updateData = {};
      updateData[action] = finalKey;

      chrome.storage.local.set(updateData, () => {
        button.textContent = getFriendlyKeyName(finalKey);
        button.classList.remove("recording");
        
        // Refresh guides
        chrome.storage.local.get(["keyUp", "keyLeft", "keyDown", "keyRight", "keyClick", "keyRightClick", "keyMiddleClick", "keyToggleMode", "keyBack", "keyForward", "keySpeedBoost"], (settings) => {
          updateDynamicGuides(settings);
        });

        cleanupRecordingState();
      });
    };

    window.addEventListener("keydown", activeRecordingListener, { capture: true });
  }

  function cancelRecording() {
    if (!currentRecordingAction) return;

    const action = currentRecordingAction;
    const button = keycapButtons[action];
    
    cleanupRecordingState();

    if (button) {
      button.classList.remove("recording");
      // Restore previous key name
      chrome.storage.local.get([action], (result) => {
        button.textContent = getFriendlyKeyName(result[action]);
      });
    }
  }

  function cleanupRecordingState() {
    if (activeRecordingListener) {
      window.removeEventListener("keydown", activeRecordingListener, { capture: true });
      activeRecordingListener = null;
    }
    currentRecordingAction = null;
  }

  function updateModeTabsUI(mode) {
    modeTabs.forEach(tab => {
      if (tab.getAttribute("data-mode") === mode) {
        tab.classList.add("active");
      } else {
        tab.classList.remove("active");
      }
    });

    if (mode === "cursor") {
      cursorSettingsGroup.classList.remove("hidden");
    } else {
      cursorSettingsGroup.classList.add("hidden");
    }
  }

  function getFriendlyKeyName(code) {
    if (!code) return "None";
    if (code === "Space") return "Space";
    if (code === "Enter") return "Enter";
    if (code.startsWith("Key")) return code.substring(3);
    if (code.startsWith("Digit")) return code.substring(5);
    if (code === "ArrowUp") return "↑";
    if (code === "ArrowDown") return "↓";
    if (code === "ArrowLeft") return "←";
    if (code === "ArrowRight") return "→";
    return code;
  }

  function updateDynamicGuides(keys) {
    const guideUp = document.getElementById("guide-key-up");
    const guideLeft = document.getElementById("guide-key-left");
    const guideDown = document.getElementById("guide-key-down");
    const guideRight = document.getElementById("guide-key-right");
    const guideClick = document.getElementById("kbd-click-key");
    const guideRightClick = document.getElementById("kbd-right-click-key");
    const guideMiddleClick = document.getElementById("kbd-middle-click-key");
    const guideToggleMode = document.getElementById("kbd-toggle-mode-key");
    const guideBack = document.getElementById("guide-key-back");
    const guideForward = document.getElementById("guide-key-forward");
    const guideSpeedBoost = document.getElementById("guide-key-speed-boost");

    const keyUp = keys.keyUp || "ArrowUp";
    const keyLeft = keys.keyLeft || "ArrowLeft";
    const keyDown = keys.keyDown || "ArrowDown";
    const keyRight = keys.keyRight || "ArrowRight";
    const keyClick = keys.keyClick || "";
    const keyRightClick = keys.keyRightClick || "KeyE";
    const keyMiddleClick = keys.keyMiddleClick || "KeyR";
    const keyToggleMode = keys.keyToggleMode || "KeyQ";
    const keySpeedBoost = keys.keySpeedBoost || "Shift";
    const keyBack = keys.keyBack || "";
    const keyForward = keys.keyForward || "";

    if (guideUp) guideUp.textContent = getFriendlyKeyName(keyUp);
    if (guideLeft) guideLeft.textContent = getFriendlyKeyName(keyLeft);
    if (guideDown) guideDown.textContent = getFriendlyKeyName(keyDown);
    if (guideRight) guideRight.textContent = getFriendlyKeyName(keyRight);
    if (guideClick) guideClick.textContent = getFriendlyKeyName(keyClick);
    if (guideRightClick) guideRightClick.textContent = getFriendlyKeyName(keyRightClick);
    if (guideMiddleClick) guideMiddleClick.textContent = getFriendlyKeyName(keyMiddleClick);
    if (guideToggleMode) guideToggleMode.textContent = getFriendlyKeyName(keyToggleMode);
    if (guideSpeedBoost) guideSpeedBoost.textContent = getFriendlyKeyName(keySpeedBoost);
    if (guideBack) guideBack.textContent = getFriendlyKeyName(keyBack);
    if (guideForward) guideForward.textContent = getFriendlyKeyName(keyForward);
  }

  // Listen for storage changes from background / shortcut keys to keep settings UI in sync
  chrome.storage.onChanged.addListener((changes, areaName) => {
    if (areaName !== "local") return;
    
    if (changes.enabled !== undefined) {
      enabledToggle.checked = changes.enabled.newValue !== false;
    }
    if (changes.mode !== undefined) {
      updateModeTabsUI(changes.mode.newValue || "cursor");
    }
  });

  const manageShortcutsBtn = document.getElementById("manage-shortcuts-btn");
  const shortcutsModal = document.getElementById("shortcuts-modal");
  const closeModalBtn = document.getElementById("close-modal-btn");
  const openAddonsTabBtn = document.getElementById("open-addons-tab-btn");

  if (manageShortcutsBtn && shortcutsModal) {
    manageShortcutsBtn.addEventListener("click", (e) => {
      e.preventDefault();
      shortcutsModal.classList.remove("hidden");
    });
  }

  if (closeModalBtn && shortcutsModal) {
    closeModalBtn.addEventListener("click", () => {
      shortcutsModal.classList.add("hidden");
    });
  }

  if (openAddonsTabBtn && shortcutsModal) {
    openAddonsTabBtn.addEventListener("click", (e) => {
      e.preventDefault();
      chrome.tabs.create({ url: "about:addons" });
      shortcutsModal.classList.add("hidden");
    });
  }
});
