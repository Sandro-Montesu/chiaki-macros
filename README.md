# chiaki-macro

Record and replay gamepad macros for [Chiaki-ng](https://github.com/streetpea/chiaki-ng) remote play.
Supports OCR-based orchestration for automated farming loops, with headless operation
via Xvfb for Raspberry Pi / servers.

## Quick install

```bash
./install.sh
```

Installs: python3-evdev, tesseract-ocr, xvfb, imagemagick, udev rules, symlinks.

## Usage

```bash
chiaki-macro record my_macro           # CTRL+C to stop
chiaki-macro play my_macro             # 1 replay
chiaki-macro play my_macro -n 10       # 10 replays
chiaki-macro play my_macro -n -1       # infinite
chiaki-macro play my_macro -n 10 --screenshot-at 23.5
chiaki-macro list
chiaki-macro delete my_macro
chiaki-macro devices
chiaki-macro import path/to/macros.json
chiaki-macro collage name --parts macro1 macro2
chiaki-macro ocr-test --region "800,50,200,40"
```

## Headless mode

```bash
# Terminal 1: start Chiaki on virtual display
chiaki-macro headless-start PS5-226 192.168.1.x

# Terminal 2: run orchestration (auto-detects Xvfb for screenshots)
chiaki-macro orchestrate farm.toml -n -1 --log log.txt

# Stop
chiaki-macro headless-stop
chiaki-macro headless-status
```

The gamepad bridge is created before Chiaki starts, so gamepad detection is guaranteed.
Screenshots auto-detect Xvfb :99, no env var needed.

## Orchestration

```toml
# farm.toml
[main]
macro = "main_loop"

[ocr]
enabled_at_s = 14.3
region = "982,56,17,16"
whitelist = "0123456789"

[[task]]
name = "Buy Item"
level_req = 3
macro = "buy_item"
execute_time = "after_current_macro"
completed = false
```

```bash
chiaki-macro orchestrate farm.toml -n 100
chiaki-macro orchestrate-init farm.toml   # interactive config wizard
```

## Requirements

- Python 3.11+
- python3-evdev, tesseract-ocr, xvfb, imagemagick
- /dev/uinput write access (input group)
- chiaki-ng AppImage at ~/chiaki-ng.AppImage or in PATH
