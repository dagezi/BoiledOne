# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

BoiledOne is a macOS Japanese Input Method (IME) built with InputMethodKit. It is inspired by the classic BoiledEgg IME for Emacs, with a philosophy of typing without switching explicitly between ASCII and Japanese modes.

## Build & Deploy

```bash
xcodebuild -project BoiledOne.xcodeproj -scheme BoiledOne -configuration Release build
```

The built app lands in `~/Library/Developer/Xcode/DerivedData/BoiledOne-*/Build/Products/Release/`. Deploy it:

```bash
cp -r $(xcodebuild -project BoiledOne.xcodeproj -scheme BoiledOne -configuration Release -showBuildSettings 2>/dev/null | awk '/BUILT_PRODUCTS_DIR/{print $3}')/BoiledOne.app ~/Library/Input\ Methods/
```

### Dictionary Setup (required before building)

Dictionaries must be placed in `BoiledOne/Resources/*.dict` before building, since they are bundled into the app. Files are loaded in alphabetical order; earlier filenames take priority.

**Pubdic+** (recommended — includes katakana/hiragana candidates):
```bash
./BoiledOne/buildtool/convertPubdic ../FreeWnn-Archive/PubdicPlus/pubdic.p > BoiledOne/Resources/00-pubdic.dict
```

**SKK** (SKK-JISYO.L):
```bash
./BoiledOne/buildtool/convertSkkDict ~/Downloads/SKK-JISYO.L > BoiledOne/Resources/0-zisyo-l.dict
```

## Running Tests

Unit tests only (no UI):
```bash
xcodebuild -project BoiledOne.xcodeproj -scheme BoiledOne -destination 'platform=macOS' -only-testing:BoiledOneTests test
```

All tests including UI tests (will briefly launch the app on screen):
```bash
xcodebuild -project BoiledOne.xcodeproj -scheme BoiledOne -destination 'platform=macOS' test
```

## Architecture

### Input Handling Flow

`BoiledOneInputController` (an `IMKInputController`) receives all key events. Each event is dispatched to the current `BoiledOneMode`'s `commandMap`, a list of `CommandEntry` objects that match by key code and modifier flags. If no entry matches, `fallbackCommand` is executed. Commands return a `BoiledOneCommandResult`:

- `.handled` — consumed
- `.notHandled` — not consumed (falls to fallback)
- `.reExecute` — re-dispatch the same event in the new mode (used for mode transitions)
- `.through` — pass the event to the client application

All mutable state lives in `BoiledOneContext`, which holds the current `mode`, `rawString` (pre-composition ASCII buffer), and client references.

### Modes (State Machine)

The IME is a state machine; switching modes is the primary mechanism for all feature transitions:

| Mode | File | Purpose |
|------|------|---------|
| `NoneMode` | `commands/NoneMode.swift` | Idle — any printable key starts `RawMode` |
| `RawMode` | `commands/RawMode.swift` | Accumulates ASCII input in `rawString`; Emacs-style cursor movement (C-a/e/b/f/d/h) |
| `KanaMode` | `kanaMode/KanaMode.swift` | Converts `rawString` → hiragana via `RomanConverter`; C-k cycles katakana |
| `SimpleKanziConvertMode` | `simpleKanzi/SimpleKanziCovertMode.swift` | Kanji conversion from hiragana using `SimpleDictionary` |

Transition triggers (from `RawMode`):
- `C-k` → `KanaMode`
- `C-j` → `SimpleKanziConvertMode`
- `C-l`, Space, Return, Tab → fix (commit) and return to `NoneMode`

### Roman→Kana Conversion

`RomanConverter` (`roman/RomanConverter.swift`) takes the `rawString` and converts it to hiragana using `defaultRomanTable`. The table is sorted longest-match-first. It also returns a `[Int: Int]` map from hiragana character positions back to source offsets (needed for cancel/undo tracking).

### Dictionary

`SimpleDictionary` loads all `*.dict` files from the app bundle's resource directory at startup. Format: one entry per line, `source dest` (space-separated, hiragana source). Lines starting with `;` are comments. Entries are sorted by source length descending after loading.

`SimpleKanziConverter` performs greedy left-to-right matching: it finds all dictionary entries whose `source` is a prefix of the remaining input, presents them as candidates, and advances on fix.

### Adding a New Command

1. Define a `BoiledOneCommand` (name + handler closure) in the relevant mode file.
2. Add a `CommandEntry` to the mode's `commandMap` in that mode's `init()`.
3. The handler receives `BoiledOneContext`; mutate `context.mode` to switch modes, `context.rawString` to modify the buffer, or call `context.insertToClient(_:)` to commit text.
