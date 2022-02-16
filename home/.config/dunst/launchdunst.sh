#!/bin/sh

killall -q dunst

dunst -config ~/.cache/wal/dunstrc &
