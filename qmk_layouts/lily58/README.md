# Lily58 keymap
You can import the JSON file on [QMK configurator](https://config.qmk.fm). It will be single lined. To prettify it, use `jq . minimal_vim.json`. That will make for easier reviews. To make it into a single line and be able to import it into GMK Configurator, run `jq . -c minimal_vim.json`.

## Add new folder
```bash
ln -s ~/repos/dotfiles/lily58/minimal_vim/ $HOME/qmk_firmware/keyboards/lily58/keymaps/minimal_vim
```

## Convert into `keymap.c`
```bash
qmk json2c minimal_vim.json -o layout.c
qmk cformat keymap.c
```

## Compile
```bash
qmk compile -kb lily58 -km minimal_vim
```

## Flash
```bash
qmk flash -kb lily58 -km minimal_vim
```

# QMK setup
Run both as sudo and user

```bash
pipx install qmk
qmk setup
```

And run `qmk setup` first as non-sudo. This is to install the dependencies.


Install the `udev rules` (in `/etc/udev/rules.d`) and run:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Now you can run `qmk` as non-root.
