qmk json2c crsnox.json -o layout.c
qmk cformat layout.c
qmk cformat keymap.c
qmk compile -kb lily58 -km crsnox
