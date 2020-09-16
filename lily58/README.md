# Lily58 keymap
You can import the JSON file on [QMK configurator](https://config.qmk.fm). It will be single lined. To prettify it, use `jq . minimal_vim.json`. That will make for easier reviews. To make it into a single line and be able to import it into GMK Configurator, run `jq . -c minimal_vim.json`.

## Convert into `keymap.c`
```bash
qmk json2c minimal_vim.json
```

## Compile
```bash
qmk compile $(pwd)/minimal_vim.json
```

## Flash
```bash
qmk flash -kb lily58 -km minimal_vim
```
