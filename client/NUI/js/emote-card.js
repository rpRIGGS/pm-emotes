const escapeHtml = (value) => String(value ?? "").replace(/[&<>"']/g, (char) => ({
  "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
}[char]));

/** Shared card markup for normal, search and favorites results. */
export function createEmoteCardMarkup(emote, icons = {}, { placementEnabled = true } = {}) {
  const name = escapeHtml(emote.name ?? emote.emoteName);
  const type = escapeHtml(emote.emoteType);
  const label = escapeHtml(emote.label ?? emote.name ?? emote.emoteName);
  const emoji = type === "Emojis";
  if (emoji) {
    return `<button class="btn btn-emote btn-emoji noto-color-emoji-regular${emote.isFavorite ? " btn-emote-favorite" : ""}" type="button" data-emoteid="${name}" data-emotetype="${type}" data-label="${label}">${label}</button>`;
  }

  const icon = escapeHtml(icons[emote.emoteType] || "");
  const favorite = emote.isFavorite ? " is-favorite btn-emote-favorite" : "";
  const placeAction = placementEnabled && !["Emojis", "Expressions", "Walks", "Shared"].includes(emote.emoteType)
    ? `<button class="emote-card-action place" type="button" data-card-action="place" data-emoteid="${name}" data-emotetype="${type}" data-label="${label}" title="Place emote" aria-label="Place ${label}">⌖</button>`
    : "";
  const positionAction = emote.canPosition
    ? `<button class="emote-card-action position" type="button" data-card-action="position" data-emoteid="${name}" data-emotetype="${type}" data-label="${label}" title="Adjust emote position" aria-label="Adjust ${label} position">⤢</button>`
    : "";

  return `<div class="emote-card${favorite}" data-emoteid="${name}" data-emotetype="${type}" data-label="${label}">
    <button class="btn btn-emote${emote.isFavorite ? " btn-emote-favorite" : ""}" type="button" data-emoteid="${name}" data-emotetype="${type}" data-label="${label}" aria-label="Play ${label}">${icon ? `${icon} ` : ""}${label}</button>
    <div class="emote-card-actions">
      <button class="emote-card-action play" type="button" data-card-action="play" data-emoteid="${name}" data-emotetype="${type}" data-label="${label}" title="Use emote" aria-label="Use ${label}">▶</button>
      ${placeAction}
      ${positionAction}
      <button class="emote-card-action favorite${favorite}" type="button" data-card-action="favorite" data-emoteid="${name}" data-emotetype="${type}" data-label="${label}" title="Toggle favorite" aria-label="Toggle favorite for ${label}" aria-pressed="${Boolean(emote.isFavorite)}">★</button>
    </div>
  </div>`;
}
