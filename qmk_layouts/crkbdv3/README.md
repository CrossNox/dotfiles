# Corne Keyboard v3 keymap
You can import the JSON file on [QMK configurator](https://config.qmk.fm). It will be single lined. To prettify it, use `jq . minimal_vim.json`. That will make for easier reviews. To make it into a single line and be able to import it into GMK Configurator, run `jq . -c minimal_vim.json`.

## Add the keymap to the QMK repo
```bash
ln -s ~/repos/dotfiles/qmk_layouts/crkbdv3/crsnox/ $HOME/qmk_firmware/keyboards/crkbd/keymaps/crsnox
```

## Convert into `keymap.c`
```bash
qmk json2c crsnox.json -o layout.c
qmk format-c layout.c
qmk format-c keymap.c
```

## Compile
```bash
qmk compile -kb crkbd -km crsnox
```

## All the above
```bash
bash compile.sh
```

## Flash
Using an Elite C v4, so use the `dfu` bootloader.

```bash
qmk flash -kb crkbd -km crsnox -bl dfu
```
