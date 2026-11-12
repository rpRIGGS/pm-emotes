// Optional PM AutoShot WebP preview overlay. Falls back silently when assets
// have not been deployed; no impact on normal PM Emotes playback.
const preview = document.createElement('img');
preview.id = 'pm-autoshot-preview';
preview.alt = 'Animated emote preview';
preview.setAttribute('aria-hidden', 'true');
Object.assign(preview.style, {
  position: 'fixed', right: '2rem', bottom: '5rem', width: '256px',
  height: '256px', objectFit: 'contain', pointerEvents: 'none',
  zIndex: '200', display: 'none', background: 'rgba(15,15,20,.75)',
  border: '1px solid #0438ff', borderRadius: '10px'
});
document.body.appendChild(preview);
let entries = {};
let selected = null;
fetch('previews/manifest.json')
  .then(response => response.ok ? response.json() : null)
  .then(data => {
    if (data && data.version === 1 && data.entries) {
      entries = data.entries;
      // Keyboard focus may already be on an emote when the manifest loads.
      // Re-render that selection instead of waiting for another hover.
      const current = document.activeElement?.closest?.('button[data-emoteid][data-emotetype]');
      if (current) { selected = null; show(current); }
    }
  })
  .catch(() => {});
function hide() {
  preview.style.display = 'none';
  preview.removeAttribute('src');
  selected = null;
}
function show(button) {
  if (!button?.dataset?.emoteid || !button?.dataset?.emotetype) {
    hide();
    return;
  }
  const key = button.dataset.emotetype + ':' + button.dataset.emoteid;
  if (selected === key) return;
  selected = key;
  const file = entries[key];
  if (!file || !/^previews\/[A-Za-z0-9_-]+\.webp$/.test(file)) {
    preview.style.display = 'none';
    preview.removeAttribute('src');
    return;
  }
  preview.src = file;
  preview.style.display = 'block';
}
document.addEventListener('focusin', event => {
  const button = event.target.closest?.('button[data-emoteid][data-emotetype]');
  if (button) show(button);
  else if (event.target.closest?.('.menu-container')) hide();
});
document.addEventListener('mouseover', event => {
  const button = event.target.closest?.('button[data-emoteid][data-emotetype]');
  if (button) show(button);
  else if (event.target.closest?.('.menu-container')) hide();
});
document.addEventListener('mouseleave', event => {
  if (event.target.closest?.('.menu-container')) {
    hide();
  }
}, true);
window.addEventListener('message', event => {
  if (event.data?.type === 'BUILD_EMOTE_MENUS') hide();
});
