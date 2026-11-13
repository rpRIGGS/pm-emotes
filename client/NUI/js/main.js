"use strict";
import { ClearHTMLContainer, HandleSidebarButtonPress, ExecuteNUICallback, PlaySoundFrontend, HandleEmoteFilter, HandleEmoteSearch, querySelectorVisible } from './utils.js';
import { Locale, Popover } from './classes.js'
import { createPreviewPanel } from './preview-panel.js'
import { createEmoteCardMarkup } from './emote-card.js'


const SIDE_NAVIGATION = document.querySelector(".side-navigation");
const CONTENT_CONTAINER = document.querySelector(".content-container");
const SEARCH_CONTAINER = document.querySelector(".search-container");
const SEARCH_BAR = SEARCH_CONTAINER.querySelector(".search-input");
let MENUS = CONTENT_CONTAINER.querySelectorAll(".menu");
const FOOTER_TEXT = document.querySelector(".footer-text");
const PM_PREVIEW = createPreviewPanel();
PM_PREVIEW.initialize();

export let EMOTE_TYPE_ICONS = {}
export let CONFIG;
export let UsingMouse = false;
let selectedPreviewButton = null;
let compactMode = localStorage.getItem("pmEmotesCompact") === "true";
let windowOffset = (() => {
    try { return JSON.parse(localStorage.getItem("pmEmotesWindowOffset") || "{\"x\":0,\"y\":0}"); }
    catch (_) { return {x: 0, y: 0}; }
})();
let scrollPositions = (() => {
    try { return JSON.parse(localStorage.getItem("pmEmotesScrollPositions") || "{}"); }
    catch (_) { return {}; }
})();

function applyCompactMode() {
    document.body.classList.toggle("compact-menu", compactMode);
    document.querySelector("#compact-toggle")?.setAttribute("aria-pressed", String(compactMode));
    document.querySelector("#compact-toggle")?.setAttribute("title", compactMode ? "Return to full menu" : "Toggle compact menu");
}

function applyWindowOffset() {
    const root = document.querySelector(".main-container");
    if (root) root.style.transform = compactMode ? `translate(${Number(windowOffset.x) || 0}px, ${Number(windowOffset.y) || 0}px)` : "";
}

function refreshCompactCategories(selectedMenu) {
    const select = document.querySelector("#compact-category-select");
    if (!select) return;
    const current = selectedMenu || select.value;
    select.replaceChildren();
    document.querySelectorAll(".side-navigation [data-action='openMenu']").forEach((button) => {
        if (button.closest(".hidden")) return;
        const option = document.createElement("option");
        option.value = button.dataset.menu;
        option.textContent = button.querySelector(".nav-label")?.textContent || button.textContent.trim();
        select.append(option);
    });
    if ([...select.options].some((option) => option.value === current)) select.value = current;
    else select.value = document.querySelector(".sidebar-button-active .btn-sidebar")?.dataset.menu || "emotes-menu";
}

applyCompactMode();
applyWindowOffset();
refreshCompactCategories();

document.querySelector("#compact-toggle")?.addEventListener("click", () => {
    compactMode = !compactMode;
    localStorage.setItem("pmEmotesCompact", String(compactMode));
    applyCompactMode();
});

document.querySelector("#compact-category-select")?.addEventListener("change", (event) => {
    document.querySelector(`.side-navigation [data-menu="${CSS.escape(event.target.value)}"]`)?.click();
});

document.querySelector("#reset-menu-settings")?.addEventListener("click", () => {
    compactMode = false;
    windowOffset = {x: 0, y: 0};
    scrollPositions = {};
    localStorage.removeItem("pmEmotesCompact");
    localStorage.removeItem("pmEmotesWindowOffset");
    localStorage.removeItem("pmEmotesScrollPositions");
    document.querySelectorAll(".menu").forEach((menu) => { menu.scrollTop = 0; });
    document.querySelector("#emote_search").value = "";
    document.querySelector("#sort-emotes").value = "asc";
    applyCompactMode();
    applyWindowOffset();
});

let positioningMode = false;
let positionUpdateTimer = null;
let positioningPreviousMouse = false;
const positionOverlay = document.querySelector("#positioning-overlay");
const positionGizmo = document.querySelector("#position-gizmo");
const positionInputs = {
    x: document.querySelector("#position-x"),
    y: document.querySelector("#position-y"),
    z: document.querySelector("#position-z"),
    rotZ: document.querySelector("#position-rot"),
};
let gizmoDrag = null;

function displayPositionValues(values = {}) {
    for (const [key, input] of Object.entries(positionInputs)) {
        if (!input) continue;
        if (Number.isFinite(Number(values[key]))) input.value = String(values[key]);
        const output = document.querySelector(`#position-${key === "rotZ" ? "rot" : key}-value`);
        if (output) output.textContent = key === "rotZ" ? `${Number(input.value).toFixed(0)}°` : Number(input.value).toFixed(2);
    }
}

function finishPositioning(save) {
    if (!positioningMode) return;
    positioningMode = false;
    clearTimeout(positionUpdateTimer);
    positionOverlay.hidden = true;
    document.body.classList.remove("positioning-mode");
    ExecuteNUICallback("FINISH_EMOTE_POSITIONING", {save, restoreMouse: positioningPreviousMouse});
}

Object.values(positionInputs).forEach((input) => input?.addEventListener("input", () => {
    const values = Object.fromEntries(Object.entries(positionInputs).map(([key, el]) => [key, Number(el.value)]));
    displayPositionValues(values);
    clearTimeout(positionUpdateTimer);
    positionUpdateTimer = setTimeout(() => ExecuteNUICallback("UPDATE_EMOTE_POSITION", values), 35);
}));
positionGizmo?.addEventListener("mousedown", (event) => {
    const handle = event.target.closest?.("[data-gizmo-axis]");
    if (!positioningMode || !handle) return;
    event.preventDefault();
    event.stopPropagation();
    const axis = handle.dataset.gizmoAxis;
    const rect = positionGizmo.getBoundingClientRect();
    const startAngle = Math.atan2(event.clientY - (rect.top + rect.height / 2), event.clientX - (rect.left + rect.width / 2)) * 180 / Math.PI;
    gizmoDrag = {
        axis, x: event.clientX, y: event.clientY, startAngle,
        initial: Object.fromEntries(Object.entries(positionInputs).map(([key, input]) => [key, Number(input.value)])),
    };
});
window.addEventListener("mousemove", (event) => {
    if (!gizmoDrag) return;
    const {axis, x, y, startAngle, initial} = gizmoDrag;
    if (axis === "rotZ") {
        const rect = positionGizmo.getBoundingClientRect();
        const angle = Math.atan2(event.clientY - (rect.top + rect.height / 2), event.clientX - (rect.left + rect.width / 2)) * 180 / Math.PI;
        let delta = angle - startAngle;
        if (delta > 180) delta -= 360;
        if (delta < -180) delta += 360;
        positionInputs.rotZ.value = String(initial.rotZ + delta);
    } else {
        const dx = Math.max(-150, Math.min(150, event.clientX - x));
        const dy = Math.max(-150, Math.min(150, event.clientY - y));
        if (axis === "x") positionInputs.x.value = String(initial.x + dx * .005);
        if (axis === "y") positionInputs.y.value = String(initial.y - dy * .005);
        if (axis === "z") positionInputs.z.value = String(initial.z - dy * .005);
    }
    const input = positionInputs[axis === "rotZ" ? "rotZ" : axis];
    input?.dispatchEvent(new Event("input", {bubbles: true}));
});
window.addEventListener("mouseup", () => { gizmoDrag = null; });
positionOverlay?.addEventListener("contextmenu", (event) => event.preventDefault());
document.querySelector("#position-save")?.addEventListener("click", () => finishPositioning(true));
document.querySelector("#position-cancel")?.addEventListener("click", () => finishPositioning(false));
document.addEventListener("keyup", (event) => {
    if (positioningMode && event.key === "Escape") {
        event.preventDefault();
        event.stopImmediatePropagation();
        finishPositioning(false);
    }
}, true);
CONTENT_CONTAINER.addEventListener("scroll", (event) => {
    const menu = event.target.closest?.(".menu");
    const menuName = [...(menu?.classList || [])].find((name) => name.endsWith("-menu"));
    if (!menuName || menuName === "search-menu") return;
    scrollPositions[menuName] = menu.scrollTop;
    localStorage.setItem("pmEmotesScrollPositions", JSON.stringify(scrollPositions));
}, true);

const dragHeader = document.querySelector(".header-container");
dragHeader?.addEventListener("mousedown", (event) => {
    if (!compactMode || event.target.closest("button, .close-hint")) return;
    const start = {x: event.clientX, y: event.clientY, offset: {...windowOffset}};
    const move = (moveEvent) => {
        windowOffset = {x: start.offset.x + moveEvent.clientX - start.x, y: start.offset.y + moveEvent.clientY - start.y};
        applyWindowOffset();
    };
    const finish = () => {
        localStorage.setItem("pmEmotesWindowOffset", JSON.stringify(windowOffset));
        window.removeEventListener("mousemove", move);
        window.removeEventListener("mouseup", finish);
    };
    window.addEventListener("mousemove", move);
    window.addEventListener("mouseup", finish);
});

function getEmoteButton(target) {
    const card = target?.closest?.(".emote-card");
    if (card) return card.querySelector(".btn-emote[data-emoteid][data-emotetype]");
    return target?.closest?.("[data-emoteid][data-emotetype]") || null;
}

function selectPreview(target) {
    selectedPreviewButton = getEmoteButton(target);
    PM_PREVIEW.select(selectedPreviewButton);
    const favorite = document.querySelector("#preview-favorite");
    favorite?.classList.toggle("is-favorite", Boolean(selectedPreviewButton?.classList.contains("btn-emote-favorite")));
    favorite?.setAttribute("aria-pressed", String(Boolean(selectedPreviewButton?.classList.contains("btn-emote-favorite"))));
}

function updateEmoteCount(menu = CONTENT_CONTAINER.querySelector(".grid")) {
    const count = menu?.querySelectorAll(".btn-emote:not(.btn-style-reset):not(.hidden), .btn-emoji:not(.hidden)").length ?? 0;
    const countText = count.toLocaleString();
    const headerCount = document.querySelector("#emote-count");
    const footerCount = document.querySelector("#footer-emote-count");
    if (headerCount) headerCount.textContent = `${countText} available`;
    if (footerCount) footerCount.textContent = countText;
}
window.PMUpdateEmoteCount = updateEmoteCount;

function routeSelectedPreview(type) {
    routeEmoteButton(selectedPreviewButton, type);
}

function routeEmoteButton(button, type) {
    const data = button?.dataset;
    if (!data?.emoteid || !data.emotetype || data.emoteid === "_reset") return;
    ExecuteNUICallback("ROUTE_EMOTE", {type, emoteName: data.emoteid, emoteType: data.emotetype});
}

function toggleFavorite(button) {
    if (!button?.dataset?.emoteid || !button.dataset.emotetype) return;
    ExecuteNUICallback("FAVORITE_EMOTE", {
        emoteName: button.dataset.emoteid,
        emoteType: button.dataset.emotetype,
        emoteLabel: button.dataset.label || button.dataset.emoteid,
    }).then(async (res) => {
        const result = await res.json();
        if (!result.favorites) return;
        const favoritesMenu = document.querySelector(".favorites-menu");
        const favorites = new Set(result.favorites.map((emote) => `${emote.emoteType}:${emote.name}`));
        const positionable = new Set([...document.querySelectorAll(".emote-card[data-emoteid]")]
            .filter((card) => card.querySelector("[data-card-action='position']"))
            .map((card) => `${card.dataset.emotetype}:${card.dataset.emoteid}`));
        document.querySelectorAll(".btn-emote[data-emoteid][data-emotetype], .emote-card[data-emoteid][data-emotetype]").forEach((emoteButton) => {
            const isFavorite = favorites.has(`${emoteButton.dataset.emotetype}:${emoteButton.dataset.emoteid}`);
            emoteButton.classList.toggle("btn-emote-favorite", isFavorite);
            emoteButton.classList.toggle("is-favorite", isFavorite);
            emoteButton.querySelector?.("[data-card-action=favorite]")?.classList.toggle("is-favorite", isFavorite);
            emoteButton.querySelector?.("[data-card-action=favorite]")?.setAttribute("aria-pressed", String(isFavorite));
        });
        ClearHTMLContainer(".favorites-menu");
        result.favorites.forEach((emote) => {
            favoritesMenu?.insertAdjacentHTML("beforeend", createEmoteCardMarkup({...emote, isFavorite: true, canPosition: positionable.has(`${emote.emoteType}:${emote.name}`)}, EMOTE_TYPE_ICONS, {placementEnabled: CONFIG?.PlacementEnabled !== false}));
        });
        if (selectedPreviewButton) {
            document.querySelector("#preview-favorite")?.classList.toggle("is-favorite", selectedPreviewButton.classList.contains("btn-emote-favorite"));
        }
        updateEmoteCount();
    });
}

document.querySelector("#preview-use-emote")?.addEventListener("click", () => routeSelectedPreview("emote"));
document.querySelector("#preview-place-emote")?.addEventListener("click", () => routeSelectedPreview("placement"));
document.querySelector("#preview-favorite")?.addEventListener("click", () => toggleFavorite(selectedPreviewButton));
document.querySelector("#quick-favorites")?.addEventListener("click", () => document.querySelector("#favorites-menu-btn")?.click());
document.querySelector("#sort-emotes")?.addEventListener("change", (event) => {
    const menu = CONTENT_CONTAINER.querySelector(".grid");
    if (!menu) return;
    const reset = menu.querySelector(".btn-style-reset");
    const cards = [...menu.querySelectorAll(".emote-card, .btn-emoji")];
    cards.sort((a, b) => {
        const order = (a.dataset.label || a.dataset.emoteid || "").localeCompare(b.dataset.label || b.dataset.emoteid || "");
        return event.target.value === "desc" ? -order : order;
    });
    cards.forEach((card) => menu.appendChild(card));
    if (reset) menu.prepend(reset);
});

window.addEventListener("load", async (e) => {

    ExecuteNUICallback("NUI_READY", {}).then( async (res) => {
        const response = await res.json();
        if (!response.config) return;
        CONFIG = response.config;

        if (!CONFIG.Search) {
            SEARCH_CONTAINER.classList.add("hidden");
            document.querySelector('[data-menu="search-menu"]')?.parentElement?.remove();
        }
        if (!CONFIG.EmojiMenuEnabled) document.querySelector('[data-menu="emojis-menu"]')?.parentElement?.remove();
        if (!CONFIG.ExpressionsEnabled) document.querySelector('[data-menu="moods-menu"]')?.parentElement?.remove();
        if (!CONFIG.WalkingStylesEnabled) document.querySelector('[data-menu="walkstyles-menu"]')?.parentElement?.remove();
        if (!CONFIG.Keybinding) document.querySelector('[data-menu="keybinds-menu"]')?.parentElement?.remove();
        if (CONFIG.MenuPosition === "left") document.body.classList.add("align-left");
        if (!CONFIG.PlacementEnabled) document.querySelectorAll("[data-card-action='place']").forEach((button) => button.remove());
        refreshCompactCategories();
    })
    const LOCALES = new Locale(); // We just need to init this after the everything is loaded. The class statics will handle everything.
})

document.addEventListener('popoverAction', (e) => {
    const { action, button, popoverButton, emoteId, event } = e.detail;
    switch (action) {
        case 'groupemote':
            ExecuteNUICallback("ROUTE_EMOTE", {type: "groupemote", emoteName: button.dataset.emoteid, emoteType: button.dataset.emotetype})
            break;
        case 'placement':
            ExecuteNUICallback("ROUTE_EMOTE", {type: "placement", emoteName: button.dataset.emoteid, emoteType: button.dataset.emotetype})
            break;
        case 'set-keybind':
            ExecuteNUICallback("KEYBIND_EMOTE", {type: "set", id: (popoverButton && popoverButton.dataset.slotid) || 1, emoteName: button.dataset.emoteid, emoteType: button.dataset.emotetype, emoteLabel: button.dataset.label})
            if (!document.activeElement || document.activeElement.nodeName !== "BUTTON") querySelectorVisible(document.querySelector(".grid"))?.focus();
            break;
        case 'clear-keybind':
            ExecuteNUICallback("KEYBIND_EMOTE", {type: "clear", id: button.dataset.slotid, emoteName: button.dataset.emoteid, emoteType: button.dataset.emotetype})
            break;
        case 'favorite':
            toggleFavorite(button);
            break;
    }
});

document.addEventListener('localesLoaded', (e) => {
    // Handler for Right-click menu.
    // All logic is done through the class, sadly. Sends a `popoverAction` custom event when a button is used.
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    const emotePopover = new Popover('.btn-emote');
    ExecuteNUICallback("LOCALES_LOADED", {})
})

SIDE_NAVIGATION.addEventListener("click", (e) => {
    const TARGET = e.target.closest?.("[data-action]");

    if (TARGET && TARGET.dataset.action) {
        PM_PREVIEW.hide();
        selectedPreviewButton = null;
        HandleSidebarButtonPress(TARGET);
        const title = document.querySelector("#active-menu-title");
        if (TARGET.dataset.action === "openMenu" && title) title.textContent = TARGET.querySelector(".nav-label")?.textContent || TARGET.textContent.trim();
        if (TARGET.dataset.action === "openMenu") {
            refreshCompactCategories(TARGET.dataset.menu);
            const openedMenu = CONTENT_CONTAINER.querySelector(`.${CSS.escape(TARGET.dataset.menu)}`);
            if (openedMenu) openedMenu.scrollTop = Number(scrollPositions[TARGET.dataset.menu]) || 0;
        }
        updateEmoteCount(CONTENT_CONTAINER.querySelector(".grid"));
        return;
    }
})

let sendPreviewRequest = true

function _setupMenuEventListeners(MENUS) {
    MENUS.forEach((element) => {
        element.addEventListener("mouseover", (e) => {
            const emoteButton = getEmoteButton(e.target);
            selectPreview(emoteButton);
            const TARGET = e.target;
            if (!TARGET.dataset.emoteid) {
                FOOTER_TEXT.innerHTML = "&nbsp;"
                return;
            }
        })

        element.addEventListener("focusin", (e) => {
            const TARGET = getEmoteButton(e.target) || e.target;
            if (TARGET.matches?.("[data-emoteid]")) selectPreview(TARGET);
            PlaySoundFrontend("NAV_UP_DOWN")
            if (!TARGET.dataset.emoteid || TARGET.dataset.emotetype === "Emojis" || TARGET.dataset.emotetype === "Expressions" || TARGET.dataset.emotetype === "Walks") {
                FOOTER_TEXT.innerHTML = "&nbsp;"

                let _previewData = {}
                if (TARGET.dataset.emotetype === "Expressions") _previewData = {emoteName: TARGET.dataset.emoteid, emoteType: TARGET.dataset.emotetype}
                if (sendPreviewRequest) {
                    sendPreviewRequest = false
                    ExecuteNUICallback("PREVIEW_EMOTE", {emoteName: TARGET.dataset.emoteid, emoteType: TARGET.dataset.emotetype}).finally(() => sendPreviewRequest = true)
                }
                return;
            }

            if (sendPreviewRequest) {
                sendPreviewRequest = false
                ExecuteNUICallback("PREVIEW_EMOTE", {emoteName: TARGET.dataset.emoteid, emoteType: TARGET.dataset.emotetype}).finally(() => sendPreviewRequest = true)
            }

            FOOTER_TEXT.textContent = `/${TARGET.closest(".walkstyles-menu") ? "walk" : "e"} ${TARGET.dataset.emoteid}`
        })

        element.addEventListener("mouseleave", (e) => {
            if (UsingMouse && !e.relatedTarget?.closest?.("#pm-preview-panel")) { selectPreview(null); }
        });
        element.addEventListener("focusout", (e) => {
            if (!element.contains(e.relatedTarget) && !e.relatedTarget?.closest?.("#pm-preview-panel") && !UsingMouse) selectPreview(null);
        });
        element.addEventListener("click", (e) => {
            e.preventDefault();
            const cardAction = e.target.closest?.("[data-card-action]");
            if (cardAction) {
                const button = getEmoteButton(cardAction);
                if (!button) return;
                if (cardAction.dataset.cardAction === "play") routeEmoteButton(button, "emote");
                if (cardAction.dataset.cardAction === "place") routeEmoteButton(button, "placement");
                if (cardAction.dataset.cardAction === "position") ExecuteNUICallback("START_EMOTE_POSITIONING", {emoteName: button.dataset.emoteid, emoteType: button.dataset.emotetype});
                if (cardAction.dataset.cardAction === "favorite") toggleFavorite(button);
                return;
            }
            const TARGET = getEmoteButton(e.target);
            if (!TARGET?.dataset?.emoteid || !TARGET.dataset.emotetype) return;
            PlaySoundFrontend("SELECT");
            if (e.shiftKey) {
                // Bodge to trick the browser into thinking we right-clicked, when in fact we Shift+Entered.
                document.dispatchEvent(new CustomEvent('contextmenu', { detail: {}}));
                return;
            }
            ExecuteNUICallback("ROUTE_EMOTE", {type: "emote", emoteName: TARGET.dataset.emoteid, emoteType: TARGET.dataset.emotetype})
        })
    })
}

SEARCH_CONTAINER.addEventListener("submit", async (e) => {
    e.preventDefault();
    if (document.querySelector(".search-menu.grid")) {
        await HandleEmoteSearch();
    } else {
        await HandleEmoteFilter();
    }
    querySelectorVisible(document.querySelector(".grid"))?.focus();
})

SEARCH_CONTAINER.addEventListener("reset", (e) => {
    HandleEmoteFilter("");
})


let lastSearchInputValue = ""
SEARCH_BAR.addEventListener("input", (e) => {
    if (document.querySelector(".search-menu.grid")) return;
    if (SEARCH_BAR.value !== lastSearchInputValue) HandleEmoteFilter();
    lastSearchInputValue = SEARCH_BAR.value
})


window.addEventListener('message', (event) => {
    if (event.data.type === "POSITIONING_MODE") {
        positioningMode = Boolean(event.data.value);
        if (positioningMode) {
            positioningPreviousMouse = UsingMouse;
            displayPositionValues(event.data.values || {x: 0, y: 0, z: 0, rotZ: 0});
            positionOverlay.hidden = false;
            document.body.classList.add("positioning-mode");
        } else {
            positionOverlay.hidden = true;
            document.body.classList.remove("positioning-mode");
        }
    }
    if (event.data.type === "POSITIONING_SCREEN_POINT") {
        if (!positioningMode || !positionGizmo) return;
        if (event.data.onScreen) {
            const scale = Math.max(.4, 1 - (Number(event.data.camDist) / 30));
            positionGizmo.style.transform = `translate(${Number(event.data.screenX) * 100}vw, ${Number(event.data.screenY) * 100}vh) translate(-50%, -50%) scale(${scale})`;
            positionGizmo.classList.add("gizmo-visible");
            positionGizmo.classList.remove("gizmo-hidden");
        } else {
            positionGizmo.classList.remove("gizmo-visible");
            positionGizmo.classList.add("gizmo-hidden");
        }
    }
    if (event.data.type === 'OPEN_MENU') {
        if (!event.data.value) { PM_PREVIEW.hide(); selectedPreviewButton = null; }
        (event.data.value ? document.body.style.display = "flex" : document.body.style.display = "none")
        document.querySelector(".btn-sidebar").focus();
        event.data.shouldShowEmojiMenu ? document.querySelector(".emoji-sidebar")?.classList.remove("hidden") : document.querySelector(".emoji-sidebar")?.classList.add("hidden")
    }

    if (event.data.type === 'TOGGLE_CURSOR_INPUT') {
        (event.data.value ? document.body.classList.remove("no-cursor") : document.body.classList.add("no-cursor"))
        UsingMouse = !document.body.classList.contains("no-cursor");
    }

    if (event.data.type === 'LOAD_EMOTE_DATA') {
        // event.data.emoteData && event.data.categoryToEmotes && event.data.emoteCategories && event.data.emoteTypeIcons
        EMOTE_TYPE_ICONS = event.data.emoteTypeIcons || {}
        const emoteCategories = event.data.emoteCategories
        Object.keys(emoteCategories).forEach((key) => {
            const SIDEBAR_ANCHOR = document.querySelector(".sidebar-button-anchor");
            const MENU_ANCHOR = document.querySelector(".menu-anchor");

            SIDEBAR_ANCHOR.insertAdjacentHTML("afterend",
                `
                    <li class="sidebar-button-container">
                        <button id="${emoteCategories[key].id}-menu-btn" class="btn btn-sidebar" data-action="openMenu" data-menu="${emoteCategories[key].id}-menu"><span aria-hidden="true">${emoteCategories[key].icon}</span><span class="nav-label">${key}</span></button>
                    </li>
                `);

            MENU_ANCHOR.insertAdjacentHTML("afterend",
                `
                <article class="menu ${emoteCategories[key].id}-menu doublecolumn btn-list">
                </article>
                `)
        })
        refreshCompactCategories();
        MENUS = CONTENT_CONTAINER.querySelectorAll(".menu");
        _setupMenuEventListeners(MENUS);
        ExecuteNUICallback("INITIAL_DATA_LOADED", {})
    }

    if (event.data.type === 'BUILD_EMOTE_MENUS') {
        PM_PREVIEW.hide();
        selectedPreviewButton = null;
        const KEYS = Object.keys(event.data);
        for (const key of KEYS) {
            if (key !== "type" && key !== "keybinds") {
                const EMOTES = CONTENT_CONTAINER.querySelector(`.${key}-menu`);
                if (!EMOTES) continue;
                ClearHTMLContainer(`.${key}-menu`);
                if ((key==="moods" || key==="walkstyles") && event.data[key]?.length) {
                    // Add the (Clear Mood) button here. Nightmares for future maintainers.
                    EMOTES.insertAdjacentHTML("beforeend", `
                        <button class="btn btn-emote btn-style-reset" data-emoteid="_reset" data-emotetype="${event.data[key][0].emoteType}" data-locale="normalreset"></button>
                        `)
                }
                event.data[key].forEach((el) => {
                    if (el) EMOTES.insertAdjacentHTML("beforeend", createEmoteCardMarkup(el, EMOTE_TYPE_ICONS, {placementEnabled: CONFIG?.PlacementEnabled !== false}));
                })
            }
        }
        event.data.favorites?.forEach((emote) => {
            const ELEMENTS = Array.from(document.querySelectorAll(".btn-emote[data-emoteid], .emote-card[data-emoteid]"));
            ELEMENTS.filter((el) => el.dataset.emoteid === emote.emoteName && el.dataset.emotetype === emote.emoteType)
                .forEach((el) => {
                    el.classList.add("btn-emote-favorite", "is-favorite");
                    el.querySelector?.("[data-card-action=\"favorite\"]")?.classList.add("is-favorite");
                    el.querySelector?.("[data-card-action=\"favorite\"]")?.setAttribute("aria-pressed", "true");
                });
        })
        Locale.setLocaleStrings();
        updateEmoteCount(CONTENT_CONTAINER.querySelector(".grid"));
    }

    if (event.data.type === "BUILD_KEYBINDS_MENU") {
        // This runs every time the player opens the emote menu.
        // We need it to run like this because we don't know when the player will change their keybinds in the settings.
        const kbinds = event.data.keybinds
        const KEYBINDS_LIST_CONTAINER = document.querySelector(".keybinds-list");

        const BIND_ITEMS = Array.from(document.querySelectorAll(".keybinds-list-item"));
        BIND_ITEMS?.forEach((el) => el.remove());

        Object.keys(kbinds).sort().forEach((key) => {
            const data = kbinds[key]
            KEYBINDS_LIST_CONTAINER?.insertAdjacentHTML("beforeend",
                `
                <li class="keybinds-list-item">
                    <span class="keybind-item-text">Slot ${data.id} [ <span class="keybind-bind-text keybind-${data.id}-bind">${data.keyLabel}</span> ]</span>
                    <button class="btn btn-emote btn-keybind" data-emoteid="${data.emoteName}" data-emoteType="${data.emoteType}" data-slotid="${data.id}">${data.emoteType && data.emoteType !== 'Emojis' ? EMOTE_TYPE_ICONS[data.emoteType]+" " : ""}${data.emoteLabel || data.emoteName || Locale.translate("empty_slot")}</button>
                </li>
                `

            )
        })
        if (document.querySelector(".keybinds-menu.grid")) {
            querySelectorVisible(document.querySelector(".keybinds-list"))?.focus();
        }

        Popover.setKeybindSlots(Object.keys(kbinds).length)
    }
});

