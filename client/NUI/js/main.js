"use strict";
import { ClearHTMLContainer, HandleSidebarButtonPress, ExecuteNUICallback, PlaySoundFrontend, HandleEmoteFilter, HandleEmoteSearch, querySelectorVisible } from './utils.js';
import { Locale, Popover } from './classes.js'


const SIDE_NAVIGATION = document.querySelector(".side-navigation");
const CONTENT_CONTAINER = document.querySelector(".content-container");
const SEARCH_CONTAINER = document.querySelector(".search-container");
const SEARCH_BAR = SEARCH_CONTAINER.querySelector(".search-input");
let MENUS = CONTENT_CONTAINER.querySelectorAll(".menu");
const FOOTER_TEXT = document.querySelector(".footer-text");

export let EMOTE_TYPE_ICONS = {}
export let CONFIG;
export let UsingMouse = false;

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
            ExecuteNUICallback("FAVORITE_EMOTE", {emoteName: button.dataset.emoteid, emoteType: button.dataset.emotetype, emoteLabel: button.dataset.label}).then( async (res) => {
                const result = await res.json();
                if (!result.favorites) return;
                const ELEMENTS = Array.from(document.querySelectorAll(`.btn-emote-favorite`));
                const MENU = document.querySelector(".favorites-menu")
                ClearHTMLContainer(".favorites-menu");
                ELEMENTS.forEach((el) => el?.classList.remove("btn-emote-favorite"));
                result.favorites?.forEach((emote) => {
                    const ELEMENTS = Array.from(document.querySelectorAll(`[data-emoteid="${emote.name}"]`));
                    ELEMENTS.forEach((el) => el?.classList.add("btn-emote-favorite"));
                    MENU.insertAdjacentHTML("beforeend", `
                            <button class="btn btn-emote btn-emote-favorite" data-emoteid="${emote.name}" data-emoteType="${emote.emoteType}" data-label="${emote.label}">${emote.emoteType !== 'Emojis' ? EMOTE_TYPE_ICONS[emote.emoteType]+" " : ""}${emote.label}</button>
                            `)
                })
                if (!document.activeElement || document.activeElement.nodeName !== "BUTTON") querySelectorVisible(document.querySelector(".grid"))?.focus();
            })
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
    const TARGET = e.target.closest("[data-action]") || (e.target.closest(".sidebar-button-container") && e.target.closest(".sidebar-button-container").querySelector("[data-action]"));

    if (TARGET && TARGET.dataset.action) {
        HandleSidebarButtonPress(TARGET);
        return;
    }
})

// Serialize previews: a fast hover/focus sequence must finish on the LAST selected emote.
let pendingPreview = null;
let previewBusy = false;
let lastPreviewKey = null;
let previewTimer = null;
let previewSession = 0;

async function drainPreviewQueue() {
    if (previewBusy) return;
    previewBusy = true;
    const session = previewSession;
    try {
        while (pendingPreview && session === previewSession) {
            const next = pendingPreview;
            pendingPreview = null;
            try {
                await ExecuteNUICallback("PREVIEW_EMOTE", next);
            } catch (error) {
                console.warn("[PM Emotes] preview callback failed", error);
            }
        }
    } finally {
        previewBusy = false;
        // A previous session's in-flight callback may finish after a new menu opens.
        // Do not strand the latest selection when that happens.
        if (pendingPreview) drainPreviewQueue();
    }
}

function requestPreview(target, immediate = false) {
    const button = target?.closest?.("[data-emoteid]");
    const name = button?.dataset.emoteid || "";
    const type = button?.dataset.emotetype || "";
    const key = type + ":" + name;
    if (key === lastPreviewKey) return;
    lastPreviewKey = key;
    clearTimeout(previewTimer);
    const dispatch = () => {
        pendingPreview = { emoteName: name, emoteType: type };
        drainPreviewQueue();
    };
    if (immediate) dispatch();
    else previewTimer = setTimeout(dispatch, 110);
    if (name && type !== "Emojis" && type !== "Walks" && type !== "Expressions") {
        FOOTER_TEXT.textContent = `/e ${name}`;
    } else {
        FOOTER_TEXT.innerHTML = "&nbsp;";
    }
}

function _setupMenuEventListeners(menus) {
    menus.forEach((element) => {
        element.addEventListener("mouseover", (e) => {
            if (!UsingMouse) return;
            const button = e.target.closest?.("[data-emoteid]");
            if (button && button !== e.relatedTarget?.closest?.("[data-emoteid]")) {
                requestPreview(button);
            }
        });
        element.addEventListener("focusin", (e) => {
            const button = e.target.closest?.("[data-emoteid]");
            if (!button) return;
            PlaySoundFrontend("NAV_UP_DOWN");
            requestPreview(button, true);
        });
        element.addEventListener("click", (e) => {
            const button = e.target.closest?.("[data-emoteid]");
            if (!button || !button.dataset.emotetype) return;
            e.preventDefault();
            PlaySoundFrontend("SELECT");
            // Shift-click must not synthesize an unbound contextmenu event.
            // The existing Popover class owns right-click and action routing.
            ExecuteNUICallback("ROUTE_EMOTE", {
                type: "emote",
                emoteName: button.dataset.emoteid,
                emoteType: button.dataset.emotetype
            });
        });
    });
}

// Static menus are bound once; newly loaded custom categories bind on creation.
_setupMenuEventListeners(MENUS);

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
    if (event.data.type === 'OPEN_MENU') {
        document.body.style.display = event.data.value ? "flex" : "none";
        if (!event.data.value) {
            previewSession++;
            clearTimeout(previewTimer);
            pendingPreview = null;
            lastPreviewKey = null;
        } else {
            // A fresh menu session must not inherit a stale preview from its last opening.
            previewSession++;
            pendingPreview = null;
            lastPreviewKey = null;
        }
        if (event.data.value) {
            const activeButton = document.querySelector(".sidebar-button-active .btn-sidebar") || document.querySelector("#emotes-menu-btn");
            activeButton?.focus();
        }
        event.data.shouldShowEmojiMenu ? document.querySelector(".emoji-sidebar")?.classList.remove("hidden") : document.querySelector(".emoji-sidebar")?.classList.add("hidden");
    }

    if (event.data.type === 'TOGGLE_CURSOR_INPUT') {
        (event.data.value ? document.body.classList.remove("no-cursor") : document.body.classList.add("no-cursor"))
        UsingMouse = !document.body.classList.contains("no-cursor");
    }

    if (event.data.type === 'LOAD_EMOTE_DATA') {
        // event.data.emoteData && event.data.categoryToEmotes && event.data.emoteCategories && event.data.emoteTypeIcons
        EMOTE_TYPE_ICONS = event.data.emoteTypeIcons || {}
        const emoteCategories = event.data.emoteCategories || {}
        // Reloads must not duplicate sidebar buttons or rebind event listeners.
        document.querySelectorAll(".pm-dynamic-category").forEach((node) => node.remove());
        Object.keys(emoteCategories).forEach((key) => {
            const category = emoteCategories[key];
            if (!category?.id || !/^[a-zA-Z0-9_-]+$/.test(category.id)) return;
            const sidebarAnchor = document.querySelector(".sidebar-button-anchor");
            const menuAnchor = document.querySelector(".menu-anchor");
            if (!sidebarAnchor || !menuAnchor) return;
            const item = document.createElement("li");
            item.className = "sidebar-button-container pm-dynamic-category";
            const button = document.createElement("button");
            button.id = category.id + "-menu-btn";
            button.className = "btn btn-sidebar";
            button.dataset.action = "openMenu";
            button.dataset.menu = category.id + "-menu";
            button.textContent = category.icon || "🎬";
            const label = document.createElement("label");
            label.htmlFor = button.id;
            label.className = "btn-sidebar-label";
            label.dataset.locale = key;
            label.textContent = key;
            item.append(button, label);
            sidebarAnchor.after(item);
            const menu = document.createElement("article");
            menu.className = "menu pm-dynamic-category doublecolumn btn-list";
            menu.classList.add(category.id + "-menu");
            menuAnchor.after(menu);
        });
        MENUS = CONTENT_CONTAINER.querySelectorAll(".menu");
        _setupMenuEventListeners(CONTENT_CONTAINER.querySelectorAll(".pm-dynamic-category.menu"));
        ExecuteNUICallback("INITIAL_DATA_LOADED", {})
    }

    if (event.data.type === 'BUILD_EMOTE_MENUS') {
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
                // Build elements without HTML interpolation; catalog labels can contain
                // quotes and special characters supplied by third-party animation packs.
                const fragment = document.createDocumentFragment();
                for (const el of (event.data[key] || [])) {
                    if (!el?.emoteName || !el.emoteType) continue;
                    const button = document.createElement("button");
                    button.className = "btn btn-emote";
                    if (el.isFavorite) button.classList.add("btn-emote-favorite");
                    if (el.emoteType === "Emojis") button.classList.add("noto-color-emoji-regular");
                    button.dataset.emoteid = el.emoteName;
                    button.dataset.emotetype = el.emoteType;
                    button.dataset.label = el.label || el.emoteName;
                    button.textContent = (el.emoteType !== "Emojis" ? (EMOTE_TYPE_ICONS[el.emoteType] || "") + " " : "") + (el.label || el.emoteName);
                    fragment.appendChild(button);
                }
                EMOTES.appendChild(fragment);
            }
        }
        event.data.favorites?.forEach((emote) => {
            const ELEMENTS = Array.from(document.querySelectorAll("[data-emoteid]")).filter((el) => el.dataset.emoteid === emote.emoteName);
            ELEMENTS.forEach((el) => el?.classList.add("btn-emote-favorite"));
        })
        Locale.setLocaleStrings();
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

