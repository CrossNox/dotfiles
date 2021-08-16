# Lily58 keymap
You can import the JSON file on [QMK configurator](https://config.qmk.fm). It will be single lined. To prettify it, use `jq . minimal_vim.json`. That will make for easier reviews. To make it into a single line and be able to import it into GMK Configurator, run `jq . -c minimal_vim.json`.

## Add the keymap to the QMK repo
```bash
ln -s ~/repos/dotfiles/qmk_layouts/lily58/crsnox $HOME/qmk_firmware/keyboards/lily58/keymaps/crsnox
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

## All the above
```bash
bash compile.sh
```

## Flash
```bash
qmk flash -kb lily58 -km minimal_vim
```
