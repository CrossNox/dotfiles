# Corne Keyboard v3 keymap
You can import the JSON file on [QMK configurator](https://config.qmk.fm). It will be single lined. To prettify it, use `jq . minimal_vim.json`. That will make for easier reviews. To make it into a single line and be able to import it into GMK Configurator, run `jq . -c minimal_vim.json`.

## Add new folder
```bash
ln -s ~/repos/dotfiles/crkbdv3/crsnox/ $HOME/qmk_firmware/keyboards/crkbd/keymaps/crsnox
```

## Convert into `keymap.c`
```bash
qmk json2c minimal_vim.json -o layout.c
qmk cformat keymap.c
```

## Compile
```bash
qmk compile -kb crkbd -km crsnox
```

## Flash
```bash
qmk flash -kb crkbd -km crsnox -bl dfu
```
