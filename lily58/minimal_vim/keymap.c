#include QMK_KEYBOARD_H

#ifdef PROTOCOL_LUFA
#include "lufa.h"
#include "split_util.h"
#endif
#ifdef SSD1306OLED
#include "ssd1306.h"
#endif

extern uint8_t is_master;

enum layer_number {
  _QWERTY = 0,
  _RAISE = 1,
};

#include "layout.c"

// SSD1306 OLED update loop, make sure to enable OLED_DRIVER_ENABLE=yes in
// rules.mk
#ifdef OLED_DRIVER_ENABLE

oled_rotation_t oled_init_user(oled_rotation_t rotation) {
  if (!is_keyboard_master())
    return OLED_ROTATION_180; // flips the display 180 degrees if offhand
  return rotation;
}

// When you add source files to SRC in rules.mk, you can use functions.
const char *read_layer_state(void);
const char *read_logo(void);
void set_keylog(uint16_t keycode, keyrecord_t *record);
const char *read_keylog(void);
const char *read_keylogs(void);

// const char *read_mode_icon(bool swap);
// const char *read_host_led_state(void);
// void set_timelog(void);
// const char *read_timelog(void);

static void render_layer_state(void) {
  switch (get_highest_layer(layer_state)) {
  case _QWERTY:
    oled_write_P(PSTR("Layer: QWERTY\n"), false);
    break;
  case _RAISE:
    oled_write_P(PSTR("Layer: Raise\n"), false);
    break;
  default:
    oled_write_P(PSTR("Layer: ???\n"), false);
  }
}

static void render_eryx_logo(void) {
  static const char PROGMEM raw_logo[] = {
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   192, 240, 248, 252, 254, 255,
      255, 127, 63,  63,  63,  63,  63,  127, 255, 255, 254, 254, 252, 248, 224,
      0,   0,   128, 224, 240, 248, 252, 254, 254, 254, 255, 127, 127, 127, 15,
      15,  127, 255, 255, 255, 255, 255, 252, 192, 0,   0,   0,   0,   192, 248,
      254, 255, 255, 255, 255, 127, 15,  3,   15,  31,  127, 255, 255, 255, 255,
      252, 240, 192, 224, 248, 252, 254, 255, 255, 255, 127, 31,  15,  3,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   255, 255, 255, 255, 255, 255, 255, 62,  62,  62,  62,  62,  62,
      62,  63,  63,  63,  63,  63,  63,  63,  62,  0,   255, 255, 255, 255, 255,
      255, 255, 1,   0,   0,   0,   0,   0,   0,   0,   3,   31,  255, 255, 255,
      255, 255, 254, 224, 224, 252, 255, 255, 255, 255, 255, 31,  3,   0,   0,
      0,   0,   0,   0,   129, 227, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      247, 195, 128, 0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   3,   15,  31,  63,  127,
      255, 255, 254, 252, 252, 248, 252, 252, 254, 255, 255, 127, 127, 63,  31,
      7,   0,   0,   255, 255, 255, 255, 255, 255, 255, 0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   7,   63,  255, 255, 255, 255, 255, 255, 255,
      255, 63,  7,   0,   0,   0,   0,   128, 224, 240, 252, 255, 255, 255, 255,
      255, 63,  15,  3,   7,   15,  63,  255, 255, 255, 255, 254, 248, 240, 192,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   1,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   248, 248, 252,
      252, 255, 255, 255, 255, 127, 63,  15,  1,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,
  };
  oled_write_raw_P(raw_logo, sizeof(raw_logo));
}

void oled_task_user(void) {
  if (is_keyboard_master()) {
    // If you want to change the display of OLED, you need to change here
    // oled_write_ln(read_layer_state(), false);
    render_layer_state();
    oled_write_ln(read_keylog(), false);
    oled_write_ln(read_keylogs(), false);
    // oled_write_ln(read_mode_icon(keymap_config.swap_lalt_lgui), false);
    // oled_write_ln(read_host_led_state(), false);
    // oled_write_ln(read_timelog(), false);
  } else {
    render_eryx_logo();
    // oled_write(read_logo(), false);
  }
}
#endif // OLED_DRIVER_ENABLE

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  if (record->event.pressed) {
#ifdef OLED_DRIVER_ENABLE
    set_keylog(keycode, record);
#endif
    // set_timelog();
  }
  return true;
}
