qmk json2c crsnox_choc.json -o layout.c
clang-format -i layout.c
clang-format -i keymap.c
qmk compile -kb crkbd -km crsnox_choc
