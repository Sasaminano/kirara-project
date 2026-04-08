#include "xparameters.h"
#include "xil_io.h"
//#include "xil_printf.h" this takes too much address space so we cannot use it with the code below
#include "sleep.h"
#include "platform.h"


// ch1 output
// [2:0] sprite_sel
// [12:3] sprite_x
// [22:13] sprite_y
// [25:23] sound_sel
// [26] sound_en
//
// ch2 input
// [0] mic_active
// [1] red_detected
// [5:2] red_quadrant
// [6] imu_tilt_active
// [7] imu_shake_active

#define GPIO_CH1  0x0
#define GPIO_CH2  0x8

#define PACK_CMD(sel, x, y, snd, snd_en) \
		((((snd_en) & 0x1) << 26) | (((snd) & 0x7) << 23) | \
		(((y) & 0x3FF) << 13) | (((x) & 0x3FF) << 3) | ((sel) & 0x7))

#define SENSOR_MIC(r) ((r) & 0x01)
#define SENSOR_CAM(r) (((r) >> 1) & 0x01)
#define SENSOR_QUAD(r) (((r) >> 2) & 0x0F)
#define SENSOR_TILT(r) (((r) >> 6) & 0x01)
#define SENSOR_SHAKE(r) (((r) >> 7) & 0x01)

#define SPR_SLEEP 0
#define SPR_STANDING 1
#define SPR_RUN 2
#define SPR_SHAKE_L 3
#define SPR_SHAKE_R 4

#define SND_WAKE 0
#define SND_SPRINT 1
#define SND_SLIDE 2
#define SND_SHAKE 3

#define CENTER_X  520
#define CENTER_Y  240
#define TILT_X	120
#define TILT_Y	240

// 1 tick = poll ms
#define POLL_MS 100
#define SLEEP_TIMEOUT_TICKS 50 // 5 seconds
#define WAKE_TICKS 5
#define ANIM_HOLD_TICKS 5
#define TILT_TICKS 6 // slide for 0.6s
#define CAM_STAND_TICKS 20 // 2s standing
#define SHAKE_PAIRS 3 // 3 l/r frames

// state machine
typedef enum {
	ST_IDLE,
	ST_WAKE,
	ST_STANDING,
	ST_CAM,
	ST_CAM_STAND,
	ST_TILT,
	ST_SHAKE_L,
	ST_SHAKE_R
} state_t;

typedef enum {
	EVT_NONE,
	EVT_MIC,
	EVT_CAM,
	EVT_TILT,
	EVT_SHAKE
} event_t;

static u32 gpio_base;

static void set_sprite(int sel, int x, int y) {
	Xil_Out32(gpio_base + GPIO_CH1, PACK_CMD(sel, x, y, 0, 0));
}

static void set_sprite_sound(int sel, int x, int y, int snd) {
	Xil_Out32(gpio_base + GPIO_CH1, PACK_CMD(sel, x, y, snd, 1));
}

static void quad_to_xy(u32 quad, int *x, int *y) {
	switch (quad) {
		case 0x1: *x = 120; *y =  80; break;
		case 0x2: *x = 920; *y =  80; break;
		case 0x4: *x = 120; *y = 400; break;
		case 0x8: *x = 920; *y = 400; break;
		default:  *x = CENTER_X; *y = CENTER_Y; break;
	}
}

static event_t poll_event(int *out_quad) {
	u32 s = Xil_In32(gpio_base + GPIO_CH2);
	*out_quad = SENSOR_QUAD(s);

	if (SENSOR_MIC(s)) return EVT_MIC;
	if (SENSOR_CAM(s)) return EVT_CAM;
	if (SENSOR_TILT(s)) return EVT_TILT;
	if (SENSOR_SHAKE(s)) return EVT_SHAKE;
	return EVT_NONE;
}

static state_t start_sequence(event_t evt, int quad, int *cam_x, int *cam_y,
		int *anim_ticks, int *shake_left) {

	switch (evt) {
		case EVT_MIC:
			return ST_STANDING;

		case EVT_CAM:
			quad_to_xy(quad, cam_x, cam_y);
			set_sprite_sound(SPR_RUN, *cam_x, *cam_y, SND_SPRINT);
			*anim_ticks = ANIM_HOLD_TICKS;
			return ST_CAM;

		case EVT_TILT:
			set_sprite_sound(SPR_SHAKE_L, TILT_X, TILT_Y, SND_SLIDE);
			*anim_ticks = TILT_TICKS;
			return ST_TILT;

		case EVT_SHAKE:
			*shake_left = SHAKE_PAIRS * 2;
			set_sprite_sound(SPR_SHAKE_L, CENTER_X, CENTER_Y, SND_SHAKE);
			*anim_ticks = ANIM_HOLD_TICKS;
			return ST_SHAKE_L;

		default:
			return ST_STANDING;
	}
}

int main() {
	gpio_base = XPAR_AXI_GPIO_0_BASEADDR;

	state_t state = ST_IDLE;
	event_t pending_evt = EVT_NONE;
	int pending_quad = 0;
	int sleep_ticks = 0;
	int anim_ticks = 0;
	int shake_left = 0;
	int cam_x = CENTER_X, cam_y = CENTER_Y;

	set_sprite(SPR_SLEEP, CENTER_X, CENTER_Y);

	while (1) {
		int quad = 0;
		event_t evt = poll_event(&quad);

		switch (state) {

		case ST_IDLE:
			if (evt != EVT_NONE) {
				pending_evt = evt;
				pending_quad = quad;
				set_sprite_sound(SPR_STANDING, CENTER_X, CENTER_Y, SND_WAKE);
				anim_ticks = WAKE_TICKS;
				state = ST_WAKE;
			}
			break;


		case ST_WAKE:
			// clear sound_en on the next tick so audio module sees a clean edge
			set_sprite(SPR_STANDING, CENTER_X, CENTER_Y);

			if (--anim_ticks <= 0) {
				state = start_sequence(pending_evt, pending_quad,
						&cam_x, &cam_y, &anim_ticks, &shake_left);
				sleep_ticks = SLEEP_TIMEOUT_TICKS;
			}
			break;


		case ST_STANDING:
			set_sprite(SPR_STANDING, CENTER_X, CENTER_Y);

			if (evt != EVT_NONE) {
				state = start_sequence(evt, quad,
						&cam_x, &cam_y, &anim_ticks, &shake_left);
				sleep_ticks = SLEEP_TIMEOUT_TICKS;
			}
			else if (--sleep_ticks <= 0) {
				set_sprite(SPR_SLEEP, CENTER_X, CENTER_Y);
				state = ST_IDLE;
			}
			break;


		case ST_CAM:
			set_sprite(SPR_RUN, cam_x, cam_y);

			if (--anim_ticks <= 0) {
				set_sprite(SPR_STANDING, cam_x, cam_y);
				anim_ticks = CAM_STAND_TICKS;
				state = ST_CAM_STAND;
			}
			break;

		case ST_CAM_STAND:
			if (--anim_ticks <= 0) {
				set_sprite(SPR_STANDING, CENTER_X, CENTER_Y);
				sleep_ticks = SLEEP_TIMEOUT_TICKS;
				state = ST_STANDING;
			}
			break;


		case ST_TILT:
			set_sprite(SPR_SHAKE_L, TILT_X, TILT_Y);

			if (--anim_ticks <= 0) {
				set_sprite(SPR_STANDING, CENTER_X, CENTER_Y);
				sleep_ticks = SLEEP_TIMEOUT_TICKS;
				state = ST_STANDING;
			}
			break;


		case ST_SHAKE_L:
			set_sprite(SPR_SHAKE_L, CENTER_X, CENTER_Y);

			if (--anim_ticks <= 0) {
				shake_left--;
				if (shake_left <= 0) {
					set_sprite(SPR_STANDING, CENTER_X, CENTER_Y);
					sleep_ticks = SLEEP_TIMEOUT_TICKS;
					state = ST_STANDING;
				}
				else {
					set_sprite(SPR_SHAKE_R, CENTER_X, CENTER_Y);
					anim_ticks = ANIM_HOLD_TICKS;
					state = ST_SHAKE_R;
				}
			}
			break;

		case ST_SHAKE_R:
			set_sprite(SPR_SHAKE_R, CENTER_X, CENTER_Y);

			if (--anim_ticks <= 0) {
				shake_left--;
				if (shake_left <= 0) {
					set_sprite(SPR_STANDING, CENTER_X, CENTER_Y);
					sleep_ticks = SLEEP_TIMEOUT_TICKS;
					state = ST_STANDING;
				}
				else {
					set_sprite(SPR_SHAKE_L, CENTER_X, CENTER_Y);
					anim_ticks = ANIM_HOLD_TICKS;
					state = ST_SHAKE_L;
				}
			}
			break;
		}

		//xil_printf("st:%d evt:%d\r\n", state, evt);

		usleep(POLL_MS * 1000);
	}

	return 0;
}
