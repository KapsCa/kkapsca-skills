"use strict";

// Host-path scanner for the "Check No Host-Specific Leaks" gate.
//
// Extracted from the inline scanner in .github/workflows/pr-validation.yml so
// it can be unit-tested (tests/host-path-scan.test.cjs). CommonJS on purpose:
// the workflow loads it with require() and node --test runs it with no
// dependencies and no build step.
//
// scan(text) returns at most one finding per pattern: { label, snippet }.
// Before matching, the text is scanned on several surfaces — the raw text plus
// normalized variants (URL-decoded, JSON-escaped slashes, file:// URL prefix
// stripped) — so a path that only appears escaped is still found. The first
// surface that matches wins, so the snippet stays as close to the original
// text as possible.
//
// Regexes are spelled with [/] instead of the \/ escape on purpose: the
// scanner runs on its own PR diff too, and a regex source containing the
// \/ escape reproduces the forbidden literal on the unescaped surface and
// fails the gate on itself. [/] is the same literal slash, byte-safe.

// The documented placeholder form (/mnt/<drive>/...) is how the docs warn
// against these paths: it is neutralized before matching, on every surface,
// exactly as the inline scanner did.
const DOCUMENTED_PLACEHOLDER = /[/]mnt[/][A-Za-z][/]\.{3}/g;

// One entry per forbidden form; the order is the report order. The first four
// are the original inline patterns, unchanged in behavior. The last two are
// the new detections: absolute Windows and macOS homes with a real user.
// Generic placeholder forms (C:\Users\<usuario>\, /Users/<usuario>/) cannot
// match because a real user name never starts with "<". The standard
// non-user directories (Public, Default, Default User, All Users, Shared,
// Guest) exist on every machine, so naming them is not a host leak and the
// negative lookaheads keep them clean.
const PATTERNS = [
  { pattern: /[/]home[/][A-Za-z0-9._-]+[/]/, label: "absolute /home/<user>/ path" },
  { pattern: /[/]mnt[/][A-Za-z][/]/, label: "WSL mount path /mnt/<drive>/" },
  { pattern: /~[/]\.pi[/]gentle-ai/, label: "local Pi config path" },
  { pattern: /~[/]\.gentle-shell/, label: "local shell-tool config path" },
  {
    pattern:
      /[A-Za-z]:[/\\]Users[/\\](?!Public[/\\]|Default User[/\\]|Default[/\\]|All Users[/\\]|Shared[/\\]|Guest[/\\])[A-Za-z0-9._-]+[/\\]/i,
    label: "absolute Windows path C:\\Users\\<user>\\",
  },
  {
    pattern: /[/]Users[/](?!Shared[/]|Guest[/])[A-Za-z0-9._-]+[/]/i,
    label: "absolute /Users/<user>/ path (macOS home)",
  },
];

// URL encoding: a path can be written with percent escapes. %5C is the
// backslash a Windows path needs; without it, C%3A%5CUsers would stay hidden.
function urlDecode(text) {
  return text.replace(/%2F/gi, "/").replace(/%3A/gi, ":").replace(/%5C/gi, "\\");
}

// JSON/JS escaping: "\/" and "\\" collapse to "/" and "\".
function unescapeSlashes(text) {
  return text.replace(/\\[/]/g, "/").replace(/\\\\/g, "\\");
}

// file:// URLs: file:///home/<user>/x hides the path behind a URL scheme.
function stripFileScheme(text) {
  return text.replace(/file:[/][/]/gi, "");
}

function surfaces(text) {
  return [text, urlDecode(text), unescapeSlashes(text), stripFileScheme(text)];
}

function scan(text) {
  const raw = typeof text === "string" ? text : String(text ?? "");
  const findings = [];
  const allSurfaces = surfaces(raw);
  for (const { pattern, label } of PATTERNS) {
    for (const surface of allSurfaces) {
      // Neutralize the documented placeholder on every surface, as the
      // inline scanner did on the raw text.
      const scannable = surface.replace(DOCUMENTED_PLACEHOLDER, " ");
      const match = scannable.match(pattern);
      if (match) {
        findings.push({ label, snippet: match[0] });
        break;
      }
    }
  }
  return findings;
}

module.exports = { PATTERNS, DOCUMENTED_PLACEHOLDER, scan };
