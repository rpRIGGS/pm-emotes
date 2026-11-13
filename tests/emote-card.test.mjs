import test from "node:test";
import assert from "node:assert/strict";
import { createEmoteCardMarkup } from "../client/NUI/js/emote-card.js";

test("RPEmotes cards expose play, placement and favorite actions", () => {
  const markup = createEmoteCardMarkup({
    name: "dance_a", emoteType: "Emotes", label: "Dance A", isFavorite: true,
  }, {Emotes: "🎬"});

  assert.match(markup, /class="emote-card is-favorite btn-emote-favorite"/);
  assert.match(markup, /data-card-action="play"/);
  assert.match(markup, /data-card-action="place"/);
  assert.match(markup, /data-card-action="favorite"[^>]*aria-pressed="true"/);
  assert.match(markup, /data-emoteid="dance_a" data-emotetype="Emotes"/);
});

test("eligible emotes get a position adjustment action", () => {
  const eligible = createEmoteCardMarkup({name: "sit", emoteType: "Emotes", label: "Sit", canPosition: true});
  const ineligible = createEmoteCardMarkup({name: "wave", emoteType: "Emotes", label: "Wave", canPosition: false});
  assert.match(eligible, /data-card-action="position"/);
  assert.doesNotMatch(ineligible, /data-card-action="position"/);
});

test("cards do not offer unsupported placement actions", () => {
  for (const emoteType of ["Emojis", "Expressions", "Walks", "Shared"]) {
    const markup = createEmoteCardMarkup({name: "sample", emoteType, label: "Sample"});
    assert.doesNotMatch(markup, /data-card-action="place"/, `${emoteType} cannot be placed`);
  }
  assert.doesNotMatch(createEmoteCardMarkup({name: "sample", emoteType: "Emotes", label: "Sample"}, {}, {placementEnabled: false}), /data-card-action="place"/);
});

test("emote names and labels are escaped before insertion into the NUI", () => {
  const markup = createEmoteCardMarkup({name: `x\" onfocus=\"alert(1)`, emoteType: "Emotes", label: `<img src=x onerror=alert(1)>`});
  assert.doesNotMatch(markup, /<img src=x/);
  assert.match(markup, /&lt;img src=x onerror=alert\(1\)&gt;/);
  assert.match(markup, /x&amp;quot;|x&quot;/);
});
