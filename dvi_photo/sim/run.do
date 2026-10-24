onerror {quit -code 1 -f}
if {![file isdirectory sim/work_waterfall]} {vlib sim/work_waterfall}
vlog -sv -work sim/work_waterfall +incdir+src src/tmds_encoder.v src/piano_keymap.v src/piano_score_rom.v src/waterfall_engine.v src/piano_roll_bitmap.v src/piano_scene.v src/video_source.v sim/tb_tmds.v sim/tb_waterfall.v sim/tb_roll_bitmap.v sim/tb_scene.v sim/tb_video.v
foreach test {tb_tmds tb_waterfall tb_roll_bitmap tb_scene tb_video} {
    vsim -lib sim/work_waterfall $test
    onfinish stop
    run -all
    if {[examine -radix unsigned /$test/passed] != 1} {quit -code 1 -f}
    quit -sim
}
quit -code 0 -f
