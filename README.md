# Kirara Project
This is a project for ECE 532 G14 at the University of Toronto for 2026W.
Our design tree is as follows:
```
.
└── kirara_final_demo_refactor
    ├── docs
    ├── kirara_final_demo_refactor.cache
    ├── kirara_final_demo_refactor.hw
    ├── kirara_final_demo_refactor.ip_user_files
    ├── kirara_final_demo_refactor.runs
    ├── kirara_final_demo_refactor.sdk
    │   └── imu
    │       └── src
    │           ├── lscript.ld
    │           ├── main.c
    │           ├── platform.c
    │           ├── platform_config.h
    │           └── platform.h
    ├── kirara_final_demo_refactor.sim
    ├── kirara_final_demo_refactor.srcs
    ├── kirara_final_demo_refactor.tmp
    ├── kirara_final_demo_refactor.xpr
    ├── pmod_nav_hw_controller_1.0
    ├── README.md
    ├── rgb2vga_v1_0
    └── src
        ├── mem
        │   ├── kirara_background_640x360_idx6_bayer4x4.mem
        │   ├── kirara_bg_palette_6bit.mem
        │   ├── kirara_palette_5bit.mem
        │   ├── kirara_run_240x240_idx5.mem
        │   ├── kirara_shake_2912.mem
        │   ├── kirara_shake_left_240x240_idx5.mem
        │   ├── kirara_shake_right_240x240_idx5.mem
        │   ├── kirara_sleep_240x240_idx5.mem
        │   ├── kirara_slide_4757.mem
        │   ├── kirara_sprint_2357.mem
        │   ├── kirara_standing_240x240_idx5.mem
        │   └── kirara_wake_2816.mem
        └── verilog
            ├── audio_loudness.v
            ├── audio_loudness_wrapper.v
            ├── audio_test_tone.v
            ├── camera_wrapper.v
            ├── i2c_sender.vhd
            ├── imu_wrapper.v
            ├── input_integrate_unit.v
            ├── ov7670_capture.vhd
            ├── ov7670_controller.vhd
            ├── ov7670_registers.vhd
            ├── red_q_detect.v
            ├── seven_seg_driver.v
            └── video_kirara_stub_800x600.v

```

Most notably our src files are in the `src/` folder with the `src/mem` containing the mem files corresponding to the audio, sprites, and background assets and `src/verilog` containing the `.vhd` and `.v` source files.

The `kirara_final_demo_refactor.sdk` contains the code for the MicroBlaze with `kirara_final_demo_refactor.sdk/imu/src` containing the '.c' source code for the event and animation code.

The `pmod_nav_hw_controller_1.0` contains our custom packaged IP for the PmodNAV.

The `rgb2vga_v1_0` contains the third-party IP code from the Vivado library for rgb2gva.

Link to Video: https://drive.google.com/file/d/1X8w4vfApDGSPWFrsuDxEXEj6QSSLt1qx/view?usp=sharing 
