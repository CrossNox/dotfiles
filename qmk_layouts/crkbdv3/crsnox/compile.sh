qmk json2c crsnox.json -o layout.c
qmk format-c layout.c
qmk format-c keymap.c
qmk compile -kb crkbd -km crsnox
