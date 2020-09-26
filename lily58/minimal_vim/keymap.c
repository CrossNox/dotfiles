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

static void render_mutt_logo(void) {
  static const char PROGMEM raw_logo[] = {
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   128, 128, 192, 192, 64,  64,  64,  64,  64,  192, 192, 128, 0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   240, 124, 14,  3,   129, 225, 248, 254, 254,
      255, 255, 252, 224, 224, 224, 129, 3,   7,   28,  248, 0,   0,   0,   252,
      252, 252, 252, 248, 224, 224, 240, 252, 252, 252, 252, 252, 252, 252, 252,
      0,   0,   252, 252, 252, 252, 60,  60,  60,  252, 252, 252, 252, 60,  60,
      60,  60,  60,  252, 252, 252, 252, 60,  60,  60,  0,   0,   252, 252, 252,
      252, 60,  60,  252, 252, 248, 240, 128, 240, 252, 252, 252, 252, 248, 252,
      60,  60,  252, 252, 252, 252, 60,  188, 252, 252, 252, 252, 252, 252, 224,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   15,
      62,  120, 254, 255, 255, 255, 255, 255, 255, 127, 63,  63,  63,  191, 191,
      223, 111, 60,  15,  0,   0,   0,   63,  63,  63,  63,  7,   15,  15,  7,
      63,  63,  63,  63,  15,  31,  63,  63,  60,  60,  63,  63,  31,  15,  0,
      0,   0,   63,  63,  63,  31,  0,   0,   0,   0,   0,   63,  63,  63,  63,
      0,   0,   0,   0,   0,   63,  63,  63,  63,  60,  60,  63,  31,  31,  63,
      63,  63,  31,  15,  15,  15,  63,  63,  63,  56,  63,  63,  63,  63,  60,
      63,  63,  31,  15,  15,  15,  31,  63,  63,  60,  0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   1,   3,   3,
      3,   3,   2,   2,   3,   3,   1,   1,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
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
    render_mutt_logo();
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
