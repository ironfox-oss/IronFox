(function () {
  // Prevent duplicate injections
  if (window.virtualCursorInjected) return;
  window.virtualCursorInjected = true;

  // Extension state
  let settings = {
    enabled: true,
    mode: "cursor", // "cursor" | "spatial"
    speed: 8,
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
    ignoreInputs: false,
    cursorSize: 18,
    cursorColor: "#38bdf8",
    cursorBorderColor: "#ffffff",
    cursorGlow: true,
    cursorOpacity: 0.8
  };

  // Synchronously register all key and window listeners at document_start to beat page scripts in registration priority
  window.addEventListener("keydown", handleKeyDown, { capture: true });
  window.addEventListener("keyup", handleKeyUp, { capture: true });
  window.addEventListener("blur", handleWindowBlur);
  window.addEventListener("resize", handleWindowResize);
  window.addEventListener("scroll", handleWindowScroll, { passive: true });
  window.addEventListener("message", handleFrameMessage);
  window.addEventListener("focus", handleWindowFocus);

  // Physics state for smooth movement
  let cursorX = window.innerWidth / 2;
  let cursorY = window.innerHeight / 2;
  let cursorVelocityX = 0;
  let cursorVelocityY = 0;
  const acceleration = 0.25;
  const friction = 0.85;

  // Keyboard state
  const keysPressed = {};
  let isShiftPressed = false;

  // Active elements
  let hoveredElement = null;
  let spatialFocusedEl = null;
  let lastFocusedRect = { top: 0, left: 0, width: 0, height: 0 };

  // DOM Elements
  let cursorEl = null;
  let spatialFocusEl = null;

  // Loops & Animation frames
  let animationFrameId = null;
  let isLoopRunning = false;
  let spatialValidationInterval = null;
  let lastDirectionKey = "";

  // Initialize
  function init() {
    chrome.storage.local.get(Object.keys(settings), (res) => {
      Object.assign(settings, res);

      const proceed = () => {
        updateDOMStructure();
        applyDynamicStyles();

        if (settings.enabled) {
          startMovementLoop();
        }
      };

      if (!document.body) {
        if (document.readyState === "loading") {
          document.addEventListener("DOMContentLoaded", proceed);
        } else {
          // Fallback polling for interactive/complete states where body is not yet ready
          const checkBody = () => {
            if (document.body) {
              proceed();
            } else {
              setTimeout(checkBody, 50);
            }
          };
          checkBody();
        }
      } else {
        proceed();
      }
    });
  }

  // Update elements in DOM based on configuration
  function updateDOMStructure() {
    if (!settings.enabled) {
      document.documentElement.classList.remove("wasd-spatial-active");
      removeCursor();
      removeSpatialFocus();
      return;
    }

    if (settings.mode === "cursor") {
      document.documentElement.classList.remove("wasd-spatial-active");
      removeSpatialFocus();
      createCursor();
    } else if (settings.mode === "spatial") {
      document.documentElement.classList.add("wasd-spatial-active");
      removeCursor();
      createSpatialFocus();
      if (!spatialFocusedEl) {
        focusNearestToCenter();
      }
    }
  }

  // Apply visual configurations to elements
  function applyDynamicStyles() {
    const root = document.documentElement;
    root.style.setProperty("--wasd-cursor-color", settings.cursorColor);
    root.style.setProperty("--wasd-cursor-size", settings.cursorSize + "px");
    root.style.setProperty("--wasd-cursor-opacity", settings.cursorOpacity);
    root.style.setProperty("--wasd-cursor-glow", settings.cursorGlow ? `0 0 12px ${settings.cursorColor}, 0 0 4px ${settings.cursorColor}` : "0 0 0 transparent");

    if (cursorEl) {
      if (settings.cursorGlow) {
        cursorEl.classList.add("glow");
      } else {
        cursorEl.classList.remove("glow");
      }
    }

    if (spatialFocusEl) {
      if (settings.cursorGlow) {
        spatialFocusEl.classList.add("glow");
      } else {
        spatialFocusEl.classList.remove("glow");
      }
    }
  }

  // Element Creation helpers
  function createCursor() {
    if (cursorEl) return;
    cursorEl = document.createElement("div");
    cursorEl.id = "wasd-navigator-cursor";
    if (settings.cursorGlow) cursorEl.classList.add("glow");
    document.documentElement.appendChild(cursorEl);
    
    // Position cursor at its last known position
    updateCursorPosition();
  }

  function removeCursor() {
    if (cursorEl) {
      cursorEl.remove();
      cursorEl = null;
    }
    // Clean up hover states
    if (hoveredElement) {
      dispatchHoverEvents(hoveredElement, false);
      hoveredElement = null;
    }
  }

  function createSpatialFocus() {
    if (spatialFocusEl) return;
    spatialFocusEl = document.createElement("div");
    spatialFocusEl.id = "wasd-navigator-spatial-focus";
    document.body.appendChild(spatialFocusEl);
  }

  function removeSpatialFocus() {
    stopSpatialValidation();
    lastFocusedRect = { top: 0, left: 0, width: 0, height: 0 };
    if (spatialFocusEl) {
      spatialFocusEl.remove();
      spatialFocusEl = null;
    }
    if (spatialFocusedEl) {
      spatialFocusedEl.blur();
      spatialFocusedEl = null;
    }
  }

  // Keyboard Handlers
  function handleKeyDown(e) {
    if (!settings.enabled) return;

    isShiftPressed = e.shiftKey;
    const key = e.code;
    const isNavigationKey = [settings.keyUp, settings.keyLeft, settings.keyDown, settings.keyRight].includes(key);
    
    // Check click key config
    const isClickKey = (key === settings.keyClick);
    const isRightClickKey = (key === settings.keyRightClick);
    const isMiddleClickKey = (key === settings.keyMiddleClick);
    const isToggleModeKey = (key === settings.keyToggleMode);
    const isBackKey = settings.keyBack && (key === settings.keyBack);
    const isForwardKey = settings.keyForward && (key === settings.keyForward);
    const isSpeedBoostKey = (key === settings.keySpeedBoost || (settings.keySpeedBoost === "Shift" && (key === "ShiftLeft" || key === "ShiftRight")));
    const isModifier = key.startsWith("Shift") || key.startsWith("Control") || key.startsWith("Alt") || key.startsWith("Meta");

    // Track Speed Boost keypress
    if (isSpeedBoostKey) {
      keysPressed[key] = true;
      if (!isModifier && !isUserTyping()) {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();
      }
    }

    // Handle Switch Mode keypress
    if (isToggleModeKey && !isUserTyping()) {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
      const nextMode = settings.mode === "cursor" ? "spatial" : "cursor";
      chrome.storage.local.set({ mode: nextMode });
      return;
    }

    // Handle History Back keypress
    if (isBackKey && !isUserTyping()) {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
      window.history.back();
      return;
    }

    // Handle History Forward keypress
    if (isForwardKey && !isUserTyping()) {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
      window.history.forward();
      return;
    }

    // Handle ESC to blur active inputs
    if (key === "Escape" && isUserTyping()) {
      let active = document.activeElement;
      if (active) {
        // Deep traverse shadow roots if any
        let cur = active;
        while (cur.shadowRoot && cur.shadowRoot.activeElement) {
          cur = cur.shadowRoot.activeElement;
        }
        cur.blur();
        
        // Force focus to the main body to guarantee exit
        document.body.focus();
        
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();
      }
      return;
    }

    // Check typing suspension
    if (isUserTyping()) {
      // Typing suspended: Let browser handle keystrokes
      return;
    }

    // If it's a WASD key, Click key, Right Click key, or Middle Click key, intercept and prevent defaults
    if (isNavigationKey || isClickKey || isRightClickKey || isMiddleClickKey) {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();

      keysPressed[key] = true;

      // Spatial navigation triggers discretely on keydown
      if (isNavigationKey) {
        // Prevent action repeats if already held, unless repeating natively
        navigateSpatial(key);
      }

      // Handle Click Key Down
      if (isClickKey) {
        performClick();
      }

      // Handle Right Click Key Down
      if (isRightClickKey) {
        performRightClick();
      }

      // Handle Middle Click Key Down
      if (isMiddleClickKey) {
        performMiddleClick();
      }
    }
  }

  function handleKeyUp(e) {
    isShiftPressed = e.shiftKey;
    const key = e.code;
    
    const isNavigationKey = [settings.keyUp, settings.keyLeft, settings.keyDown, settings.keyRight].includes(key);
    const isClickKey = (key === settings.keyClick);
    const isRightClickKey = (key === settings.keyRightClick);
    const isMiddleClickKey = (key === settings.keyMiddleClick);
    const isToggleModeKey = (key === settings.keyToggleMode);
    const isBackKey = settings.keyBack && (key === settings.keyBack);
    const isForwardKey = settings.keyForward && (key === settings.keyForward);
    const isSpeedBoostKey = (key === settings.keySpeedBoost || (settings.keySpeedBoost === "Shift" && (key === "ShiftLeft" || key === "ShiftRight")));
    const isModifier = key.startsWith("Shift") || key.startsWith("Control") || key.startsWith("Alt") || key.startsWith("Meta");
    
    if ((isNavigationKey || isClickKey || isRightClickKey || isMiddleClickKey || isToggleModeKey || isBackKey || isForwardKey || (isSpeedBoostKey && !isModifier)) && !isUserTyping()) {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
    }

    if (keysPressed[key]) {
      delete keysPressed[key];
    }
  }

  function handleWindowBlur() {
    // Clear pressed keys when page loses focus to avoid stuck controls
    for (const key in keysPressed) {
      delete keysPressed[key];
    }
    isShiftPressed = false;
  }

  let isResizeScheduled = false;
  function handleWindowResize() {
    if (isResizeScheduled) return;
    isResizeScheduled = true;
    requestAnimationFrame(() => {
      isResizeScheduled = false;
      if (settings.mode === "cursor") {
        // Keep cursor inside window
        cursorX = Math.min(cursorX, window.innerWidth);
        cursorY = Math.min(cursorY, window.innerHeight);
        updateCursorPosition();
      } else if (settings.mode === "spatial" && spatialFocusedEl) {
        updateSpatialFocusRing();
      }
    });
  }

  let isScrollScheduled = false;
  function handleWindowScroll() {
    if (isScrollScheduled) return;
    isScrollScheduled = true;
    requestAnimationFrame(() => {
      isScrollScheduled = false;
      if (settings.mode === "spatial" && spatialFocusedEl) {
        // Need to reposition highlight ring because scrolling moves absolute coordinates
        updateSpatialFocusRing();
      }
    });
  }

  // Check if target is an editable or typing input field
  function isUserTyping() {
    if (!settings.ignoreInputs) return false;
    const active = document.activeElement;
    if (!active) return false;
    
    const tagName = active.tagName.toLowerCase();
    if (tagName === "textarea") return true;
    if (tagName === "input") {
      const type = active.type.toLowerCase();
      const nonTypingTypes = ["checkbox", "radio", "range", "button", "submit", "reset", "color", "file", "image"];
      return !nonTypingTypes.includes(type);
    }
    if (active.isContentEditable) return true;
    
    // Traverse shadow DOM
    let cur = active;
    while (cur.shadowRoot && cur.shadowRoot.activeElement) {
      cur = cur.shadowRoot.activeElement;
      const tag = cur.tagName.toLowerCase();
      if (tag === "textarea" || 
          (tag === "input" && !["checkbox", "radio", "range", "button", "submit", "reset", "color", "file", "image"].includes(cur.type.toLowerCase())) || 
          cur.isContentEditable) {
        return true;
      }
    }
    
    return false;
  }

  // Animation Loop for Cursor and Scroll modes
  function startMovementLoop() {
    if (isLoopRunning) return;
    isLoopRunning = true;
    
    function tick() {
      if (!settings.enabled || isUserTyping()) {
        isLoopRunning = false;
        return;
      }

      if (settings.mode === "cursor") {
        updateCursorMovement();
      }

      if (settings.enabled && settings.mode === "cursor") {
        animationFrameId = requestAnimationFrame(tick);
      } else {
        isLoopRunning = false;
      }
    }

    animationFrameId = requestAnimationFrame(tick);
  }

  function stopMovementLoop() {
    if (animationFrameId) {
      cancelAnimationFrame(animationFrameId);
      animationFrameId = null;
    }
    isLoopRunning = false;
  }

  // Mode 1: Virtual Cursor Movement
  function updateCursorMovement() {
    // Read input directions
    let targetVx = 0;
    let targetVy = 0;

    const baseSpeed = settings.speed;
    const isBoosted = keysPressed[settings.keySpeedBoost] || (settings.keySpeedBoost === "Shift" && isShiftPressed);
    const actualSpeed = isBoosted ? baseSpeed * 3 : baseSpeed;

    if (keysPressed[settings.keyUp]) targetVy = -actualSpeed;
    if (keysPressed[settings.keyDown]) targetVy = actualSpeed;
    if (keysPressed[settings.keyLeft]) targetVx = -actualSpeed;
    if (keysPressed[settings.keyRight]) targetVx = actualSpeed;

    // Apply acceleration and friction
    cursorVelocityX += (targetVx - cursorVelocityX) * acceleration;
    cursorVelocityY += (targetVy - cursorVelocityY) * acceleration;

    cursorVelocityX *= friction;
    cursorVelocityY *= friction;

    // Zero out extremely tiny velocities
    if (Math.abs(cursorVelocityX) < 0.05) cursorVelocityX = 0;
    if (Math.abs(cursorVelocityY) < 0.05) cursorVelocityY = 0;

    // Move coordinates
    cursorX += cursorVelocityX;
    cursorY += cursorVelocityY;

    // Track boundaries before constraints
    const hitLeft = cursorX <= 0;
    const hitRight = cursorX >= window.innerWidth;
    const hitTop = cursorY <= 0;
    const hitBottom = cursorY >= window.innerHeight;

    // Viewport bounds constraints
    cursorX = Math.max(0, Math.min(window.innerWidth, cursorX));
    cursorY = Math.max(0, Math.min(window.innerHeight, cursorY));

    // Edge scrolling logic: scroll window if moving past screen bounds
    let scrollX = 0;
    let scrollY = 0;
    const scrollFactor = 1.35;

    if (hitLeft && keysPressed[settings.keyLeft]) {
      scrollX = cursorVelocityX * scrollFactor;
    } else if (hitRight && keysPressed[settings.keyRight]) {
      scrollX = cursorVelocityX * scrollFactor;
    }

    if (hitTop && keysPressed[settings.keyUp]) {
      scrollY = cursorVelocityY * scrollFactor;
    } else if (hitBottom && keysPressed[settings.keyDown]) {
      scrollY = cursorVelocityY * scrollFactor;
    }

    if (scrollX !== 0 || scrollY !== 0) {
      window.scrollBy(scrollX, scrollY);
    }

    updateCursorPosition();
    processCursorHover();
  }

  function updateCursorPosition() {
    if (!cursorEl) return;
    cursorEl.style.transform = `translate3d(${cursorX}px, ${cursorY}px, 0) translate(-50%, -50%)`;
  }

  // Detect and style hovered elements under virtual cursor
  function processCursorHover() {
    if (!cursorEl) return;

    // Find target element. We temporarily hide cursor pointer-events via CSS (done in stylesheet)
    // so it doesn't return itself.
    const element = document.elementFromPoint(cursorX, cursorY);
    if (!element) {
      if (hoveredElement) {
        dispatchHoverEvents(hoveredElement, false);
        hoveredElement = null;
        cursorEl.classList.remove("hovering");
      }
      return;
    }

    // Traverse upwards to see if it is a clickable element
    const clickTarget = findClickableAncestor(element);
    
    if (clickTarget) {
      if (hoveredElement !== clickTarget) {
        if (hoveredElement) {
          dispatchHoverEvents(hoveredElement, false);
        }
        hoveredElement = clickTarget;
        dispatchHoverEvents(hoveredElement, true);
        cursorEl.classList.add("hovering");
      }
    } else {
      if (hoveredElement) {
        dispatchHoverEvents(hoveredElement, false);
        hoveredElement = null;
        cursorEl.classList.remove("hovering");
      }
    }
  }

  function findClickableAncestor(el) {
    let cur = el;
    while (cur && cur !== document.documentElement) {
      const tag = cur.tagName.toLowerCase();
      const role = cur.getAttribute("role");
      const hasCursorPointer = window.getComputedStyle(cur).cursor === "pointer";
      const hasOnclick = typeof cur.onclick === "function" || cur.hasAttribute("onclick");

      if (
        ["a", "button", "input", "select", "textarea"].includes(tag) ||
        role === "button" ||
        role === "link" ||
        cur.hasAttribute("tabindex") && cur.getAttribute("tabindex") !== "-1" ||
        hasCursorPointer ||
        hasOnclick
      ) {
        return cur;
      }
      cur = cur.parentElement;
    }
    return null;
  }

  // Trigger mouse hover simulation
  function dispatchHoverEvents(el, enter) {
    if (!el) return;
    
    const rect = el.getBoundingClientRect();
    const eventParams = {
      bubbles: true,
      cancelable: true,
      view: window,
      clientX: cursorX,
      clientY: cursorY,
      screenX: cursorX + window.screenX,
      screenY: cursorY + window.screenY
    };

    if (enter) {
      // Simulate Hover states
      el.dispatchEvent(new MouseEvent("mouseover", eventParams));
      el.dispatchEvent(new MouseEvent("mouseenter", eventParams));
      
      // If it's a hoverable element, we can also dispatch focus
      if (el.focus && ["input", "textarea", "select", "a", "button"].includes(el.tagName.toLowerCase())) {
        // We don't focus text inputs immediately on hover to avoid opening keyboards or losing navigation focus
        if (el.tagName.toLowerCase() !== "input" && el.tagName.toLowerCase() !== "textarea") {
          try { el.focus({ preventScroll: true }); } catch (e) {}
        }
      }
    } else {
      el.dispatchEvent(new MouseEvent("mouseout", eventParams));
      el.dispatchEvent(new MouseEvent("mouseleave", eventParams));
      
      if (el.blur && ["input", "textarea", "select", "a", "button"].includes(el.tagName.toLowerCase())) {
        try { el.blur(); } catch (e) {}
      }
    }
  }

  // Mode 2: Spatial Navigation
  function navigateSpatial(key) {
    lastDirectionKey = key;
    const candidates = getSpatialCandidates();
    if (candidates.length === 0) return;

    if (!cursorEl) {
      focusNearestToCenter();
      return;
    }

    const rectCurr = cursorEl.getBoundingClientRect();
    const cx1 = rectCurr.left + rectCurr.width / 2;
    const cy1 = rectCurr.top + rectCurr.height / 2;

    let bestCandidate = null;
    let minDistance = Infinity;

    for (const cand of candidates) {
      if (cand === cursorEl) continue;

      const rectCand = cand.getBoundingClientRect();
      const cx2 = rectCand.left + rectCand.width / 2;
      const cy2 = rectCand.top + rectCand.height / 2;

      let dx = cx2 - cx1;
      let dy = cy2 - cy1;

      // Weighted distance calculation
      let distance;
      if (key === settings.keyUp || key === settings.keyDown) {
        // Vertical priority: penalize horizontal offsets heavily
        distance = Math.abs(dy) + 3.0 * Math.abs(dx);
      } else {
        // Horizontal priority: penalize vertical offsets heavily
        distance = Math.abs(dx) + 3.0 * Math.abs(dy);
      }

      if (distance < minDistance) {
        minDistance = distance;
        bestCandidate = cand;
      }
    }

    if (bestCandidate) {
      setSpatialFocus(bestCandidate);
    } else {
      // If we are inside an iframe and there are no candidates in this direction,
      // request the parent window to navigate out of the iframe
      if (window !== window.top) {
        window.parent.postMessage({
          type: "wasd-navigate-out",
          direction: key
        }, "*");
        return;
      }

      // No focusable candidate in that direction -> scroll page in that direction!
      const scrollDistance = 220;
      let scrollX = 0;
      let scrollY = 0;

      if (scrollX !== 0 || scrollY !== 0) {
        window.scrollBy({ left: scrollX, top: scrollY, behavior: "smooth" });
        
        // After scrolling, keep the active focus ring position updated
        setTimeout(() => {
          if (settings.enabled) {
            updateSpatialFocusRing();
          }
        }, 150);
      }
    }
  }

  function getSpatialCandidates() {
    const candidates = [];
    
    function collect(root) {
      if (!root) return;
      
      const children = root.children;
      if (!children) return;

      for (let i = 0; i < children.length; i++) {
        const el = children[i];
        
        if (isFocusableCandidate(el)) {
          candidates.push(el);
        }
        
        // Traverse shadow roots recursively
        if (el.shadowRoot) {
          collect(el.shadowRoot);
        }
        
        // Traverse light DOM children recursively
        collect(el);
      }
    }
    
    function isFocusableCandidate(el) {
      const tagName = el.tagName.toLowerCase();
      
      // Filter out disabled inputs or hidden types
      if (el.disabled) return false;
      if (tagName === "input" && el.type && el.type.toLowerCase() === "hidden") return false;

      const focusableTags = ["a", "button", "input", "select", "textarea", "iframe"];
      const hasFocusRole = ["button", "link", "checkbox", "textbox"].includes(el.getAttribute("role"));
      const hasTabIndex = el.hasAttribute("tabindex") && el.getAttribute("tabindex") !== "-1";
      const isContentEditable = el.isContentEditable;
      
      if (focusableTags.includes(tagName) || hasFocusRole || hasTabIndex || isContentEditable) {
        const style = window.getComputedStyle(el);
        if (style.visibility === "hidden" || style.display === "none" || style.opacity === "0") return false;
        
        const rect = el.getBoundingClientRect();
        if (rect.width <= 0 || rect.height <= 0) return false;
        
        const isInViewport = (
          rect.bottom >= 0 &&
          rect.top <= window.innerHeight &&
          rect.right >= 0 &&
          rect.left <= window.innerWidth
        );
        
        return isInViewport;
      }
      
      return false;
    }
    
    collect(document.documentElement);
    return candidates;
  }

  function focusNearestToCenter() {
    const candidates = getSpatialCandidates();
    if (candidates.length === 0) return;

    const screenCx = window.innerWidth / 2;
    const screenCy = window.innerHeight / 2;

    let best = null;
    let minDistance = Infinity;

    for (const cand of candidates) {
      const rect = cand.getBoundingClientRect();
      const cx = rect.left + rect.width / 2;
      const cy = rect.top + rect.height / 2;

      // Distance from center of screen
      const d = Math.hypot(cx - screenCx, cy - screenCy);
      if (d < minDistance) {
        minDistance = d;
        best = cand;
      }
    }

    if (best) {
      setSpatialFocus(best);
    }
  }

  function setSpatialFocus(el) {
    if (spatialFocusedEl) {
      spatialFocusedEl.blur();
    }
    
    spatialFocusedEl = el;
    
    try {
      spatialFocusedEl.focus({ preventScroll: true });
    } catch(e) {}

    // Scroll into view smoothly if element is near borders
    spatialFocusedEl.scrollIntoView({ behavior: "smooth", block: "nearest" });
    
    // If the focused target is an iframe, post message to tell it to focus inside
    if (spatialFocusedEl.tagName.toLowerCase() === "iframe") {
      try {
        spatialFocusedEl.contentWindow.postMessage({
          type: "wasd-navigate-in",
          direction: lastDirectionKey
        }, "*");
      } catch (e) {
        console.error("Virtual Cursor: Failed to post message to iframe", e);
      }
    }

    updateSpatialFocusRing();
    startSpatialValidation();
  }

  function startSpatialValidation() {
    stopSpatialValidation();
    
    spatialValidationInterval = setInterval(() => {
      if (!settings.enabled || settings.mode !== "spatial" || !spatialFocusedEl) {
        stopSpatialValidation();
        return;
      }
      
      // Check if element is still connected to the DOM
      if (!spatialFocusedEl.isConnected) {
        removeSpatialFocus();
        return;
      }
      
      // Check if element is still visible and has dimensions
      const style = window.getComputedStyle(spatialFocusedEl);
      const isVisible = style.display !== "none" && style.visibility !== "hidden" && style.opacity !== "0";
      const rect = spatialFocusedEl.getBoundingClientRect();
      const hasSize = rect.width > 0 && rect.height > 0;
      
      if (!isVisible || !hasSize) {
        removeSpatialFocus();
        return;
      }
      
      // Keep highlighting aligned with layout shifts
      updateSpatialFocusRing();
    }, 200);
  }

  function stopSpatialValidation() {
    if (spatialValidationInterval) {
      clearInterval(spatialValidationInterval);
      spatialValidationInterval = null;
    }
  }

  function updateSpatialFocusRing() {
    if (!spatialFocusEl || !spatialFocusedEl) {
      if (spatialFocusEl) spatialFocusEl.classList.remove("active");
      return;
    }

    // Hide the parent focus ring if the active target is an iframe (the iframe's internal
    // content script will handle drawing the focus ring around the actual elements inside)
    if (spatialFocusedEl.tagName.toLowerCase() === "iframe") {
      spatialFocusEl.classList.remove("active");
      return;
    }

    const rect = spatialFocusedEl.getBoundingClientRect();
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;

    const top = Math.round(rect.top + scrollTop - 4);
    const left = Math.round(rect.left + scrollLeft - 4);
    const width = Math.round(rect.width + 8);
    const height = Math.round(rect.height + 8);

    // Check if position or size actually changed to avoid layout thrashing/reflows
    if (
      top === lastFocusedRect.top &&
      left === lastFocusedRect.left &&
      width === lastFocusedRect.width &&
      height === lastFocusedRect.height
    ) {
      spatialFocusEl.classList.add("active");
      return;
    }

    lastFocusedRect = { top, left, width, height };

    // Position overlay relative to body coordinate space using translate3d for GPU acceleration
    spatialFocusEl.style.transform = `translate3d(${left}px, ${top}px, 0)`;
    spatialFocusEl.style.width = width + "px";
    spatialFocusEl.style.height = height + "px";
    
    // Match element's rounded corners
    const elBorderRadius = window.getComputedStyle(spatialFocusedEl).borderRadius;
    if (elBorderRadius && elBorderRadius !== "0px") {
      const radiusValue = parseInt(elBorderRadius, 10);
      spatialFocusEl.style.borderRadius = (radiusValue + 4) + "px";
    } else {
      spatialFocusEl.style.borderRadius = "6px";
    }

    spatialFocusEl.classList.add("active");
  }

  // Handle messages passing between different frames (e.g. video players)
  function handleFrameMessage(e) {
    if (!settings.enabled || settings.mode !== "spatial") return;
    if (!e.data || typeof e.data !== "object") return;

    if (e.data.type === "wasd-navigate-out") {
      // Find which iframe sent this message
      const iframes = Array.from(document.querySelectorAll("iframe"));
      const sendingIframe = iframes.find(iframe => iframe.contentWindow === e.source);
      if (!sendingIframe) return;

      // Set the temporary focus origin to the iframe on the parent page
      spatialFocusedEl = sendingIframe;
      navigateSpatial(e.data.direction);
    } else if (e.data.type === "wasd-navigate-in") {
      // Focus entered from parent window into this iframe
      focusBoundaryElement(e.data.direction);
    }
  }

  function handleWindowFocus() {
    if (settings.enabled && settings.mode === "spatial" && !spatialFocusedEl) {
      setTimeout(() => {
        // If focus is indeed inside this window/document and nothing is focused
        if (document.activeElement && document.activeElement !== document.body) {
          // If activeElement is focusable, set spatial focus to it
          const candidates = getSpatialCandidates();
          if (candidates.includes(document.activeElement)) {
            spatialFocusedEl = document.activeElement;
            updateSpatialFocusRing();
          }
        } else {
          focusNearestToCenter();
        }
      }, 50);
    }
  }

  function focusBoundaryElement(direction) {
    const candidates = getSpatialCandidates();
    if (candidates.length === 0) return;

    let best = candidates[0];
    let bestVal = getBoundaryValue(best, direction);

    for (let i = 1; i < candidates.length; i++) {
      const cand = candidates[i];
      const val = getBoundaryValue(cand, direction);
      if (isBetterBoundary(val, bestVal, direction)) {
        best = cand;
        bestVal = val;
      }
    }

    setSpatialFocus(best);
  }

  function getBoundaryValue(el, direction) {
    const rect = el.getBoundingClientRect();
    switch (direction) {
      case settings.keyUp:      // Entered from bottom (moving Up)
        return rect.bottom;     // Closest to bottom of iframe
      case settings.keyDown:    // Entered from top (moving Down)
        return rect.top;        // Closest to top of iframe
      case settings.keyLeft:    // Entered from right (moving Left)
        return rect.right;      // Closest to right of iframe
      case settings.keyRight:   // Entered from left (moving Right)
        return rect.left;       // Closest to left of iframe
    }
    return 0;
  }

  function isBetterBoundary(val, bestVal, direction) {
    switch (direction) {
      case settings.keyUp:
      case settings.keyLeft:
        return val > bestVal;   // We want the maximum coordinate value (nearest to bottom/right)
      case settings.keyDown:
      case settings.keyRight:
        return val < bestVal;   // We want the minimum coordinate value (nearest to top/left)
    }
    return false;
  }

  // Scroll mode functions removed - integrated directly into cursor and spatial modes

  // Perform Simulated click action
  function performClick() {
    let target = null;
    let x = 0;
    let y = 0;

    if (settings.mode === "cursor") {
      target = hoveredElement;
      x = cursorX;
      y = cursorY;
    } else if (settings.mode === "spatial") {
      target = spatialFocusedEl;
      if (target) {
        const rect = target.getBoundingClientRect();
        x = rect.left + rect.width / 2;
        y = rect.top + rect.height / 2;
      }
    }

    // Visual ripple effect
    if (x > 0 && y > 0) {
      triggerRipple(x, y, "left");
    }

    if (target) {
      // Simulate click cycle
      const eventParams = {
        bubbles: true,
        cancelable: true,
        view: window,
        clientX: x,
        clientY: y,
        screenX: x + window.screenX,
        screenY: y + window.screenY
      };

      target.dispatchEvent(new MouseEvent("mousedown", eventParams));
      
      // Focus typing targets so user can begin entry
      if (target.focus) {
        try { target.focus(); } catch (e) {}
      }

      target.dispatchEvent(new MouseEvent("mouseup", eventParams));
      target.dispatchEvent(new MouseEvent("click", eventParams));
    }
  }

  // Perform Simulated Right click action
  function performRightClick() {
    let target = null;
    let x = 0;
    let y = 0;

    if (settings.mode === "cursor") {
      target = hoveredElement;
      x = cursorX;
      y = cursorY;
    } else if (settings.mode === "spatial") {
      target = spatialFocusedEl;
      if (target) {
        const rect = target.getBoundingClientRect();
        x = rect.left + rect.width / 2;
        y = rect.top + rect.height / 2;
      }
    }

    // Visual ripple effect
    if (x > 0 && y > 0) {
      triggerRipple(x, y, "right");
    }

    if (target) {
      const eventParams = {
        bubbles: true,
        cancelable: true,
        view: window,
        clientX: x,
        clientY: y,
        screenX: x + window.screenX,
        screenY: y + window.screenY,
        button: 2, // Right button
        buttons: 2
      };

      target.dispatchEvent(new MouseEvent("mousedown", eventParams));
      target.dispatchEvent(new MouseEvent("mouseup", eventParams));
    }
  }

  // Perform Simulated Middle click action
  function performMiddleClick() {
    let target = null;
    let x = 0;
    let y = 0;

    if (settings.mode === "cursor") {
      target = hoveredElement;
      x = cursorX;
      y = cursorY;
    } else if (settings.mode === "spatial") {
      target = spatialFocusedEl;
      if (target) {
        const rect = target.getBoundingClientRect();
        x = rect.left + rect.width / 2;
        y = rect.top + rect.height / 2;
      }
    }

    // Visual ripple effect
    if (x > 0 && y > 0) {
      triggerRipple(x, y, "middle");
    }

    if (target) {
      // Send message to background script to open anchors in background tab
      const anchor = target.closest("a");
      if (anchor && anchor.href) {
        chrome.runtime.sendMessage({ action: "openTab", url: anchor.href });
      }

      const eventParams = {
        bubbles: true,
        cancelable: true,
        view: window,
        clientX: x,
        clientY: y,
        screenX: x + window.screenX,
        screenY: y + window.screenY,
        button: 1, // Middle button
        buttons: 4
      };

      target.dispatchEvent(new MouseEvent("mousedown", eventParams));
      target.dispatchEvent(new MouseEvent("mouseup", eventParams));
      target.dispatchEvent(new MouseEvent("auxclick", eventParams));
    }
  }

  function triggerRipple(x, y, type = "left") {
    const ripple = document.createElement("div");
    ripple.className = `wasd-click-ripple ${type}-click`;
    ripple.style.left = x + "px";
    ripple.style.top = y + "px";
    
    // In spatial mode, the ripple is absolute positioned over body if scrolling
    if (settings.mode === "spatial") {
      const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
      const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;
      ripple.style.position = "absolute";
      ripple.style.left = (x + scrollLeft) + "px";
      ripple.style.top = (y + scrollTop) + "px";
      document.body.appendChild(ripple);
    } else {
      document.documentElement.appendChild(ripple);
    }

    setTimeout(() => {
      ripple.remove();
    }, 450);
  }

  // Self execute script initialization
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
