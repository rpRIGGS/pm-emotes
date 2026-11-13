"use strict";
import { ClearHTMLContainer, HandleSidebarButtonPress, ExecuteNUICallback, PlaySoundFrontend, HandleEmoteFilter, HandleEmoteSearch, querySelectorVisible } from './utils.js';
import { Locale, Popover } from './classes.js'
import { createPreviewPanel } from './preview-panel.js'


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

function getEmoteButton(target) {
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
    const data = selectedPreviewButton?.dataset;
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
        document.querySelectorAll(".btn-emote[data-emoteid][data-emotetype]").forEach((emoteButton) => {
            emoteButton.classList.toggle("btn-emote-favorite", favorites.has(`${emoteButton.dataset.emotetype}:${emoteButton.dataset.emoteid}`));
        });
        ClearHTMLContainer(".favorites-menu");
        result.favorites.forEach((emote) => {
            favoritesMenu?.insertAdjacentHTML("beforeend", `<button class="btn btn-emote btn-emote-favorite" data-emoteid="${emote.name}" data-emotetype="${emote.emoteType}" data-label="${emote.label}">${emote.emoteType !== 'Emojis' ? (EMOTE_TYPE_ICONS[emote.emoteType] || "")+" " : ""}${emote.label}</button>`);
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
    const buttons = [...menu.querySelectorAll(".btn-emote:not(.btn-style-reset)")];
    buttons.sort((a, b) => {
        const order = (a.dataset.label || a.dataset.emoteid || "").localeCompare(b.dataset.label || b.dataset.emoteid || "");
        return event.target.value === "desc" ? -order : order;
    });
    buttons.forEach((button) => menu.appendChild(button));
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
                    if (el) {
                        EMOTES.insertAdjacentHTML("beforeend", `
                            <button class="btn btn-emote ${el.isFavorite ? "btn-emote-favorite" : ""} ${el.emoteType === "Emojis" ? "noto-color-emoji-regular" : ""}" data-emoteid="${el.emoteName}" data-emotetype="${el.emoteType}" data-label="${el.label}">${el.emoteType !== 'Emojis' ? EMOTE_TYPE_ICONS[el.emoteType]+" " : ""}${el.label}</button>
                            `)
                    }
                })
            }
        }
        event.data.favorites?.forEach((emote) => {
            const ELEMENTS = Array.from(document.querySelectorAll(`[data-emoteid="${emote.emoteName}"]`));
            ELEMENTS.forEach((el) => el?.classList.add("btn-emote-favorite"));
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

