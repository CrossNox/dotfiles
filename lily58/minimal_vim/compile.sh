jq . minimal_vim.json > minimal_vim_pretty.json
qmk json2c minimal_vim.json -o layout.c
qmk cformat layout.c
qmk cformat keymap.c
qmk compile -kb lily58 -km minimal_vim
