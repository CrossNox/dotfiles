qmk json2c crsnox.json -o layout.c
clang-format -i layout.c
clang-format -i keymap.c
qmk compile -kb crkbd -km crsnox
