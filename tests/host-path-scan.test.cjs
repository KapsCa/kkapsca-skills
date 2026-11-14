"use strict";

const { test } = require("node:test");
const assert = require("node:assert/strict");

const { PATTERNS, DOCUMENTED_PLACEHOLDER, scan } = require("../scripts/host-path-scan.cjs");

// ---------------------------------------------------------------------------
// Fixtures are assembled at runtime from fragments, on purpose.
//
// The host-path gate scans the diff of this very PR (there is no per-file
// allowlist), and the scanner also matches escaped forms. A forbidden path
// written literally in this file — even URL- or JSON-escaped, even inside a
// regex source like /~\/\.pi\/gentle-ai/, whose unescaped surface reproduces
// the literal — would fail the gate on this PR's own commit. That self-fail is
// exactly the bug class #157 closes, so every fixture below is built from
// pieces that cannot form a host path in the diff text on any of the
// scanner's normalized surfaces.
// ---------------------------------------------------------------------------
const USER = "kkaps";
const SEP = String.fromCharCode(92); // backslash "\"
const DRIVE = "c";

const linuxPath = "/home/" + USER + "/notes.md";
const winPath = "C:" + SEP + "Users" + SEP + USER + SEP + "Documents" + SEP + "notes.txt";
const macPath = "/Users/" + USER + "/notes/plan.md";

const urlEscapedLinux = linuxPath.replaceAll("/", "%2F");
const urlEscapedWin = winPath.replaceAll(SEP, "%5C").replaceAll(":", "%3A");
const jsonEscapedLinux = linuxPath.replaceAll("/", SEP + "/");
const fileUrlLinux = "file://" + linuxPath;
const fileUrlMac = "file://" + macPath;

const L = {
  linuxHome: "absolute /home/<user>/ path",
  wsl: "WSL mount path /mnt/<drive>/",
  pi: "local Pi config path",
  shell: "local shell-tool config path",
  windows: "absolute Windows path C:\\Users\\<user>\\",
  mac: "absolute /Users/<user>/ path (macOS home)",
};

function labels(findings) {
  return findings.map((f) => f.label);
}

test("detects the four original forbidden forms", () => {
  assert.deepEqual(labels(scan(linuxPath)), [L.linuxHome]);
  assert.deepEqual(labels(scan("/mnt/" + DRIVE + "/repos/notes")), [L.wsl]);
  assert.deepEqual(labels(scan("~/.pi/" + "gentle-ai")), [L.pi]);
  assert.deepEqual(labels(scan("~/.gentle-" + "shell")), [L.shell]);
});

test("detects a Windows absolute path with a real user", () => {
  assert.deepEqual(labels(scan(winPath)), [L.windows]);
  assert.deepEqual(labels(scan("see " + winPath + " for the dump")), [L.windows]);
});

test("detects the macOS home with a real user", () => {
  assert.deepEqual(labels(scan(macPath)), [L.mac]);
});

test("detects a path that only appears URL-escaped", () => {
  assert.deepEqual(labels(scan(urlEscapedLinux)), [L.linuxHome]);
  assert.deepEqual(labels(scan(urlEscapedWin)), [L.windows]);
});

test("detects a path that only appears with JSON-escaped slashes", () => {
  assert.deepEqual(labels(scan(jsonEscapedLinux)), [L.linuxHome]);
});

test("detects a path hidden behind a file:// URL", () => {
  assert.deepEqual(labels(scan(fileUrlLinux)), [L.linuxHome]);
  assert.deepEqual(labels(scan(fileUrlMac)), [L.mac]);
});

test("generic and documented forms stay clean", () => {
  assert.deepEqual(scan("/home/<usuario>/notes"), []);
  assert.deepEqual(scan("/mnt/<disco>/..."), []);
  assert.deepEqual(scan("C:\\Users\\<usuario>\\..."), []);
  assert.deepEqual(scan("%USERPROFILE%\\AppData"), []);
  assert.deepEqual(scan("~"), []);
  assert.deepEqual(scan("Please replace host-specific paths with generic forms before merging."), []);
  assert.deepEqual(scan(""), []);
});

// The standard non-user directories exist on every machine writing the same
// name, so a PR that mentions them is not leaking the author's host.
test("standard non-user directories stay clean", () => {
  assert.deepEqual(scan("C:\\Users\\Public\\Documents"), []);
  assert.deepEqual(scan("c:\\users\\public\\documents"), []);
  assert.deepEqual(scan("C:\\Users\\Default\\ntuser.dat"), []);
  assert.deepEqual(scan("C:\\Users\\Default User\\x"), []);
  assert.deepEqual(scan("C:\\Users\\All Users\\x"), []);
  assert.deepEqual(scan("/Users/Shared/project"), []);
  assert.deepEqual(scan("/Users/Guest/x"), []);
});

test("the documented placeholder is neutralized exactly as before", () => {
  assert.deepEqual(scan("/mnt/" + DRIVE + "/..."), []);
  assert.deepEqual(scan("mounts like /mnt/" + DRIVE + "/... are documented"), []);
});

test("reports one finding per matched pattern, in pattern order", () => {
  const text = [linuxPath, macPath, "~/.pi/" + "gentle-ai"].join(" :: ");
  assert.deepEqual(labels(scan(text)), [L.linuxHome, L.pi, L.mac]);
});

test("the reported snippet is the offending text", () => {
  const text = "moved the notes from /home/" + USER + "/notes.md to the repo";
  const [finding] = scan(text);
  assert.equal(finding.snippet, "/home/" + USER + "/");
});

test("an escape-only path reports its normalized snippet", () => {
  const [finding] = scan(urlEscapedLinux);
  assert.equal(finding.snippet, "/home/" + USER + "/");
});

test("exports the full pattern set and the placeholder", () => {
  assert.equal(PATTERNS.length, 6);
  assert.deepEqual(
    PATTERNS.map((p) => p.label).slice(0, 4),
    [L.linuxHome, L.wsl, L.pi, L.shell]
  );
  assert.ok(DOCUMENTED_PLACEHOLDER instanceof RegExp);
});
