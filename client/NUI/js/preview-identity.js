/**
 * Resolve PM Emotes menu entries to producer identities without guessing.
 * Ambiguous commands never receive a preview; normal emote playback is untouched.
 */
export function createPreviewIdentityResolver(manifest) {
  if (!manifest || manifest.schemaVersion !== 1 || !Array.isArray(manifest.entries)) {
    throw new Error("Unsupported preview manifest");
  }
  const byCommand = new Map();
  for (const entry of manifest.entries) {
    if (!entry || typeof entry.command !== "string" || !entry.command ||
        typeof entry.source !== "string" || typeof entry.category !== "string" ||
        typeof entry.id !== "string" || entry.format !== "apng") continue;
    const key = entry.command.toLowerCase();
    const group = byCommand.get(key) ?? [];
    group.push(entry);
    byCommand.set(key, group);
  }
  return {
    resolve(emoteName, expectedCategory = null) {
      if (typeof emoteName !== "string" || !emoteName) return null;
      const matches = byCommand.get(emoteName.toLowerCase()) ?? [];
      const candidates = expectedCategory === null
        ? matches : matches.filter((item) => item.category === expectedCategory);
      if (candidates.length !== 1) return null;
      const entry = candidates[0];
      return { id: entry.id, source: entry.source, category: entry.category, command: entry.command };
    },
    audit(emoteNames) {
      const unique = [...new Set(emoteNames.filter((name) => typeof name === "string" && name))];
      const resolved = [], ambiguous = [], missing = [];
      for (const name of unique) {
        const candidates = byCommand.get(name.toLowerCase()) ?? [];
        if (candidates.length === 1) resolved.push(name);
        else if (candidates.length > 1) ambiguous.push({ name, candidates: candidates.map((e) => e.id) });
        else missing.push(name);
      }
      return { resolved, ambiguous, missing };
    },
  };
}
