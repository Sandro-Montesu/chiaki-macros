# chiaki-macro

Record and replay gamepad macros for [Chiaki](https://github.com/streetpea/chiaki-ng) remote play.

## Install

```bash
sudo apt install -y python3-evdev
sudo usermod -a -G input $USER
echo 'KERNEL=="uinput", MODE="0660", GROUP="input"' | sudo tee /etc/udev/rules.d/99-uinput.rules
sudo udevadm control --reload-rules
# log out and back in
ln -s $(pwd)/chiaki-macro ~/.local/bin/chiaki-macro
```

## Usage

```bash
chiaki-macro record my_macro        # CTRL+C to stop
chiaki-macro play my_macro          # 1 replay
chiaki-macro play my_macro -n 10    # 10 replays
chiaki-macro play my_macro -n -1    # infinite
chiaki-macro play my_macro -n 10 --screenshot-at 23.5
chiaki-macro list
chiaki-macro delete my_macro
chiaki-macro devices
```

## Requirements

- Python 3
- `python3-evdev`
- `/dev/uinput` write access (input group)
