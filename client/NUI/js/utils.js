"use strict";
import { Locale } from "./classes.js";
import { CONFIG, EMOTE_TYPE_ICONS } from "./main.js";

export function ClearHTMLContainer(elementClass) {
    const ELEMENT = document.querySelector(elementClass);
    let retval = 0;
    if (ELEMENT) {
        retval = ELEMENT.children.length;
        ELEMENT.innerHTML = "";
    }
    return retval;
}

export function HandleSidebarButtonPress(el) {
    if (!el || !el.dataset.action) return;
    const CONTENT_CONTAINER = document.querySelector(".content-container");
    const SEARCH_CONTAINER = document.querySelector(".search-container");
    const SEARCH_BAR = SEARCH_CONTAINER.querySelector(".search-input");
    switch (el.dataset.action) {
        case "openMenu":
            const PREVIOUS_ACTIVE_BUTTON_CONTAINER = document.querySelector(".sidebar-button-active");
            const PREVIOUS_ACTIVE_BUTTON = PREVIOUS_ACTIVE_BUTTON_CONTAINER?.querySelector(".btn-sidebar");

            if (PREVIOUS_ACTIVE_BUTTON_CONTAINER) {
                PREVIOUS_ACTIVE_BUTTON_CONTAINER.classList.remove("sidebar-button-active");
                CONTENT_CONTAINER.querySelectorAll(".grid").forEach((el) => {
                    el.classList.remove("grid")
                })
            }
                
            const BUTTON_CONTAINER = el.closest(".sidebar-button-container")
            if (BUTTON_CONTAINER) BUTTON_CONTAINER.classList.add("sidebar-button-active");
            const OPENED_MENU = CONTENT_CONTAINER.querySelector(`.${el.dataset.menu}`)
            OPENED_MENU?.classList.add("grid");
            PlaySoundFrontend("SELECT")

            if (CONFIG.Search) {
                SEARCH_CONTAINER.classList.remove("hidden");
                if (BUTTON_CONTAINER !== PREVIOUS_ACTIVE_BUTTON_CONTAINER) {
                    SEARCH_BAR.value = "";
                    HandleEmoteFilter(""); // Bodge to clear search. Sorry.
                }
                if (OPENED_MENU?.classList.contains("keybinds-menu")) {
                    SEARCH_CONTAINER.classList.add("hidden");
                }
                OPENED_MENU?.classList.contains("search-menu") ? SEARCH_BAR.placeholder = Locale.translate("searchemotes") : SEARCH_BAR.placeholder = Locale.translate("filteremotes").replace("%s", BUTTON_CONTAINER?.querySelector("label")?.textContent || "");
            }
            if (el.dataset.menu === "search-menu") return SEARCH_CONTAINER.querySelector(".search-input").focus();
            querySelectorVisible(OPENED_MENU)?.focus();
            break;
        case "sitNearby":
            ExecuteNUICallback("SIT_NEARBY", {});
            break;
        case "cancelEmote":
            const req = ExecuteNUICallback("CANCEL_EMOTE", {}).finally((retval) => {}) 
            break;
        default:
            console.log(`What am I supposed to do with this action? (${el.dataset.action})`)
            break;
    }
}

export function HandleEmoteFilter(_search, menu = ".grid") {
    const CONTENT_CONTAINER = document.querySelector(".content-container");
    const searchValue = typeof _search !== "undefined" ? _search?.toLowerCase() : document.querySelector(".search-input").value.toLowerCase();
    const gridElements = CONTENT_CONTAINER.querySelectorAll(menu);
    
    gridElements.forEach((grid) => {
        const buttons = grid.querySelectorAll("[data-emoteid]");
        buttons.forEach((button) => {
            const emoteId = button.dataset.emoteid.toLowerCase()+button.textContent.toLowerCase();
            emoteId.includes(searchValue) ? button.classList.remove("hidden") : button.classList.add("hidden");
        })
    })
}

// Search the exact catalog already delivered by RPEmotes to the UI.
// Unlike the legacy engine search, this includes walks, expressions, props,
// custom categories and future additions without maintaining another catalog.
export async function HandleEmoteSearch(_search) {
    const container = document.querySelector(".search-menu");
    if (!container) return;
    const term = String(typeof _search !== "undefined" ? _search : document.querySelector(".search-input").value).trim().toLocaleLowerCase();
    const matches = document.createDocumentFragment();
    const seen = new Set();
    for (const source of document.querySelectorAll(".content-container .menu:not(.search-menu) [data-emoteid]")) {
        const id = source.dataset.emoteid;
        const type = source.dataset.emotetype;
        if (!id || !type || id === "_reset") continue;
        const key = type + ":" + id;
        if (seen.has(key)) continue;
        if (!(id + " " + (source.dataset.label || source.textContent)).toLocaleLowerCase().includes(term)) continue;
        seen.add(key);
        const button = source.cloneNode(true);
        button.classList.remove("hidden");
        matches.appendChild(button);
    }
    container.replaceChildren(matches);
}

export function querySelectorVisible(parent, query = ".btn") {
    const elements = parent?.querySelectorAll(query);
    let retval;
    for (const el of elements) {
        if (!el.classList.contains("hidden")) {
            retval = el;
            break;
        }
    }
    return retval;
}

export async function HandleLocales() {
    const req = await ExecuteNUICallback("GET_LOCALES", {})
    if (!req) {
        console.log("Bad locales callback: ", req)
        return {}
    };
    const LOCALES = await req.json()
    if (!LOCALES || !LOCALES.data) return {};
    
    document.querySelectorAll("[data-locale]").forEach((el) => {
        if (LOCALES.data[el.dataset.locale]) {
            LOCALES.data[el.dataset.locale] = LOCALES.data[el.dataset.locale].replace(/~.*?~/g, "").trim();
        }
    })
    return LOCALES.data;
}

export async function ExecuteNUICallback(callback, data) {
    let retval = await fetch(`https://${GetParentResourceName()}/${callback}`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json; charset=UTF-8",
			},
			body: JSON.stringify(data),
		});

    return retval
}

let playSoundAllowed = true;
export function PlaySoundFrontend(soundName) {
    if (!playSoundAllowed) return;
    playSoundAllowed = false;
    ExecuteNUICallback("PLAY_SOUND_FRONTEND", {soundName: soundName});
    setTimeout(() => {playSoundAllowed = true}, 100)
}