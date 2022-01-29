#!/bin/sh

(! pidof dunst) || killall -q dunst

dunst -config ~/.cache/wal/dunstrc &
