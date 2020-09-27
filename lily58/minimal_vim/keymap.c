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

static void render_outrun(void) {
  static const char PROGMEM raw_logo[] = {
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      2,   0,   128, 0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   4,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   4,   0,   0,   0,
      128, 192, 224, 240, 240, 248, 248, 252, 252, 252, 252, 254, 254, 252, 0,
      252, 0,   248, 0,   240, 0,   224, 0,   255, 32,  16,  16,  16,  255, 24,
      8,   8,   8,   8,   255, 4,   4,   4,   6,   6,   2,   2,   255, 255, 3,
      1,   129, 129, 129, 129, 128, 128, 128, 255, 255, 192, 192, 192, 192, 192,
      192, 192, 192, 64,  96,  96,  96,  96,  0,   16,  0,   0,   0,   1,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   16,  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   4,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   128, 248, 254, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 0,   255, 0,   255, 0,   255, 0,   255,
      0,   255, 132, 132, 132, 132, 255, 134, 134, 130, 130, 130, 255, 130, 130,
      130, 131, 131, 131, 129, 255, 255, 129, 129, 129, 129, 129, 129, 129, 129,
      129, 255, 255, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128,
      128, 0,   8,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   16,  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   16,  0,   0,
      0,   0,   0,   0,   1,   0,   0,   0,   0,   0,   0,   0,   64,  0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   2,   0,   0,   0,   1,   31,
      127, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      0,   255, 0,   255, 0,   255, 0,   255, 0,   255, 33,  33,  33,  57,  255,
      97,  97,  65,  65,  65,  255, 65,  65,  65,  193, 193, 193, 129, 255, 255,
      129, 129, 129, 129, 129, 129, 129, 129, 1,   255, 255, 1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   0,   0,   0,   0,   0,   0,
      16,  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   64,  0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   8,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   64,  0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   3,   7,   15,  15,  31,
      31,  63,  63,  63,  63,  127, 127, 63,  0,   63,  0,   31,  0,   15,  0,
      7,   0,   255, 4,   8,   8,   8,   255, 24,  16,  16,  16,  16,  255, 48,
      32,  32,  96,  96,  64,  64,  255, 255, 192, 128, 129, 129, 129, 129, 1,
      1,   1,   255, 255, 3,   3,   3,   3,   3,   3,   3,   2,   6,   6,   6,
      6,   6,
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
    render_outrun();
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
