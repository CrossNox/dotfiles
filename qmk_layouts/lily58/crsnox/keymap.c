#include QMK_KEYBOARD_H

#ifdef PROTOCOL_LUFA
#include "lufa.h"
#include "split_util.h"
#endif
#ifdef SSD1306OLED
#include "ssd1306.h"
#endif

char wpm_str[10];

extern uint8_t is_master;

enum layer_number {
  _QWERTY = 0,
  _RAISE = 1,
};

#include "layout.c"

// SSD1306 OLED update loop, make sure to enable OLED_DRIVER_ENABLE=yes in
// rules.mk
#ifdef OLED_DRIVER_ENABLE

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

#define IDLE_WPM_THRESHOLD 40 // below this wpm value your animation will idle
#define IDLE_ANIM_FRAME_DURATION 200

#define PIXELS_PER_COL 32

#define STARS 24

uint32_t anim_timer = 0;
uint32_t anim_sleep = 0;
uint8_t current_idle_frame = 0;
uint8_t current_tap_frame = 0;
uint32_t current_frame = 0;
uint32_t stars_arr[STARS][3] = {0};

oled_rotation_t oled_init_user(oled_rotation_t rotation) {
  for (uint8_t i = 0; i < STARS; ++i) {
    stars_arr[i][0] = rand() % 57;
    stars_arr[i][1] = rand() % 32;
    stars_arr[i][2] = rand() % 2;
  }
  if (!is_keyboard_master())
    return OLED_ROTATION_180; // flips the display 180 degrees if offhand
  return rotation;
}

void render_line(uint16_t lno) {
  for (uint8_t i = 0; i < PIXELS_PER_COL; ++i) {
    oled_write_pixel(lno, i, 1);
  }
}

static void render_outrun(void) {
  static const char PROGMEM raw_logo[] = {
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      128, 192, 224, 240, 240, 248, 248, 252, 252, 254, 254, 254, 254, 252, 0,
      252, 0,   248, 0,   240, 0,   224, 0,   255, 32,  16,  16,  16,  24,  24,
      8,   8,   8,   8,   12,  12,  4,   4,   6,   6,   2,   2,   2,   3,   3,
      1,   129, 129, 129, 129, 128, 128, 128, 192, 192, 192, 192, 192, 192, 192,
      192, 192, 192, 64,  96,  96,  96,  96,  0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   192, 248, 254, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 0,   255, 0,   255, 0,   255, 0,   255,
      0,   255, 132, 132, 132, 132, 134, 134, 134, 130, 130, 130, 130, 130, 130,
      130, 131, 131, 131, 129, 129, 129, 129, 129, 129, 129, 129, 129, 129, 129,
      129, 129, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128,
      128, 0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   3,   31,
      127, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      0,   255, 0,   255, 0,   255, 0,   255, 0,   255, 33,  33,  33,  33,  97,
      97,  97,  65,  65,  65,  65,  65,  65,  65,  193, 193, 193, 129, 129, 129,
      129, 129, 129, 129, 129, 129, 129, 129, 129, 129, 1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   3,   7,   15,  15,  31,
      31,  63,  63,  127, 127, 127, 127, 63,  0,   63,  0,   31,  0,   15,  0,
      7,   0,   255, 4,   8,   8,   8,   24,  24,  16,  16,  16,  16,  48,  48,
      32,  32,  96,  96,  64,  64,  64,  192, 192, 128, 129, 129, 129, 129, 1,
      1,   1,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   2,   6,   6,
      6,   6};

  void render_stars(void) {
    bool could_flip = (current_frame % 10) == 0;
    for (uint8_t i = 0; i < STARS; ++i) {
      if (could_flip && (rand() % 10 == 0)) {
        stars_arr[i][2] = !!!stars_arr[i][2];
      }
      oled_write_pixel(stars_arr[i][0], stars_arr[i][1], stars_arr[i][2]);
    }
  }

  void animation_phase(void) {
    // TODO: add defines for this logic
    current_frame = (current_frame + 1) % 45;

    oled_write_raw_P(raw_logo, sizeof(raw_logo));

    render_stars();

    // move the road
    render_line(83 + 0 + (current_frame % 9));
    render_line(83 + 9 + (current_frame % 9));
    render_line(83 + 18 + (current_frame % 9));
    render_line(83 + 27 + (current_frame % 9));
    render_line(83 + 36 + (current_frame % 9));
  }

  uint8_t current_wpm = get_current_wpm();

  if (current_wpm != 0) {
    oled_on();
    if (current_wpm <= IDLE_WPM_THRESHOLD) {
      if (timer_elapsed32(anim_timer) > IDLE_ANIM_FRAME_DURATION) {
        anim_timer = timer_read32();
        animation_phase();
      }
    } else { // we will outrun the sun
      // the faster you type the faster we will outrun the sun
      uint32_t frame_len = IDLE_ANIM_FRAME_DURATION -
                           25 * ((current_wpm - IDLE_WPM_THRESHOLD) / 10);
      if (frame_len < 100) {
        frame_len = 100;
      }
      if (timer_elapsed32(anim_timer) > frame_len) {
        anim_timer = timer_read32();
        animation_phase();
      }
    }
    anim_sleep = timer_read32();
  } else {
    if (timer_elapsed32(anim_sleep) > OLED_TIMEOUT) {
      oled_off();
    } else {
      if (timer_elapsed32(anim_timer) > IDLE_ANIM_FRAME_DURATION) {
        anim_timer = timer_read32();
        animation_phase();
      }
    }
  }
}

void oled_task_user(void) {
  if (is_keyboard_master()) {
    // If you want to change the display of OLED, you need to change here
    // oled_write_ln(read_layer_state(), false);
    render_layer_state();
    oled_write_ln(read_keylog(), false);
    oled_write_ln(read_keylogs(), false);
    sprintf(wpm_str, "WPM: %03d", get_current_wpm());
    oled_write_ln(wpm_str, false);
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
