/*
Copyright 2019 @foostan
Copyright 2020 Drashna Jaelre <@drashna>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include QMK_KEYBOARD_H
#include <stdio.h>

#include "layout.c"

// #define USB_MAX_POWER_CONSUMPTION 600

#ifdef OLED_DRIVER_ENABLE
oled_rotation_t oled_init_user(oled_rotation_t rotation) {
  if (!is_keyboard_master()) {
    return OLED_ROTATION_180; // flips the display 180 degrees if offhand
  }
  return rotation;
}

enum layer_number {
  _DEFAULT = 0,
  _LOWER = 2,
  _RAISE = 3,
  _ADJUST = 4,
};

enum layout {
  _QWERTY = 1,
  _WORKMAN = 2,
};

void keyboard_post_init_user(void) { default_layer_set(_QWERTY); }

const char *get_layout(void) {
  switch (default_layer_state) {
  case _QWERTY:
    return "QWERTY";
  case _WORKMAN:
    return "Workman";
  default:
    return "Error";
  }
}

const char *get_layer(void) {
  switch (get_highest_layer(layer_state)) {
  case _DEFAULT:
    return "Default";
  case _LOWER:
    return "Lower";
  case _RAISE:
    return "Raise";
  case _ADJUST:
    return "Adjust";
  default:
    return "Error";
  }
}

void oled_render_layer_state(void) {
  char buf[16];

  snprintf(buf, sizeof(buf), "Layout: %s", get_layout());
  oled_write_ln(buf, false);

  snprintf(buf, sizeof(buf), "Layer: %s", get_layer());
  oled_write_ln(buf, false);
}

static void render_rgbmatrix_status(bool full) {
#ifdef RGB_MATRIX_ENABLE
  char buf[23];
  if (rgb_matrix_is_enabled()) {
    snprintf(buf, sizeof(buf), "RGB %2d: %d, %d, %d", rgblight_get_mode(),
             rgblight_get_hue(), rgblight_get_sat(), rgblight_get_val());
    oled_write_ln(buf, false);
  }
#endif
}

unsigned long uptime = 0;
unsigned int iters = 0;

void render_uptime(void) {
  iters++;
  if ((iters % 10) == 0) {
    uptime++;
    iters = 0;
  }

  char buf[32];
  snprintf(buf, sizeof(buf), "Uptime: %lu0", uptime);
  oled_write_ln(buf, false);
}

void oled_render_logo(void) {
  static const char PROGMEM crkbd_logo[] = {
      0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a,
      0x8b, 0x8c, 0x8d, 0x8e, 0x8f, 0x90, 0x91, 0x92, 0x93, 0x94, 0xa0,
      0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab,
      0xac, 0xad, 0xae, 0xaf, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xc0, 0xc1,
      0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb, 0xcc,
      0xcd, 0xce, 0xcf, 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0};
  oled_write_P(crkbd_logo, false);
}

void oled_task_user(void) {
  if (is_keyboard_master()) {
    oled_render_layer_state();
    render_rgbmatrix_status(true);
    render_uptime();
  } else {
    oled_render_logo();
  }
}

#endif // OLED_DRIVER_ENABLE
