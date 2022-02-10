import pywal
import os


# Default color levels for the color cube
cubelevels = [0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF]
# Generate a list of midpoints of the above list
snaps = [(x + y) / 2 for x, y in zip(cubelevels, [0] + cubelevels)][1:]


def rgb2short(r, g, b):
    """Converts RGB values to the nearest equivalent xterm-256 color."""
    # Using list of snap points, convert RGB value to cube indexes
    r, g, b = map(lambda x: len(tuple(s for s in snaps if s < x)), (r, g, b))
    # Simple colorcube transform
    return r * 36 + g * 6 + b + 16


def split_into(s, l):
    return [int(s[y - l : y], 16) for y in range(l, len(s) + l, l)]


def color2xterm(c):
    c = c.lstrip("#")
    r, g, b = split_into(c, 2)
    return rgb2short(r, g, b)


home = os.getenv("HOME")
colors = pywal.colors.file(f"{home}/.cache/wal/colors.json")["colors"]

colors = {k: color2xterm(v) for k, v in colors.items()}

schema = {
    "BLK": "color1",
    "CHR": "color1",
    "DIR": "color4",
    "EXE": "color6",
    "REG": "color0",
    "HARDLINK": "color6",
    "SYMLINK": "color6",
    "MISSING": "color0",
    "ORPHAN": "color9",
    "FIFO": "color6",
    "SOCK": "color1",
    "OTHER": "color6",
}

xterm_schema = {k: colors[v] for k, v in schema.items()}

print(
    f"{xterm_schema['BLK']}"
    f"{xterm_schema['CHR']}"
    f"{xterm_schema['DIR']}"
    f"{xterm_schema['EXE']}"
    f"{xterm_schema['REG']}"
    f"{xterm_schema['HARDLINK']}"
    f"{xterm_schema['SYMLINK']}"
    f"{xterm_schema['MISSING']}"
    f"{xterm_schema['ORPHAN']}"
    f"{xterm_schema['FIFO']}"
    f"{xterm_schema['SOCK']}"
    f"{xterm_schema['OTHER']}"
)
