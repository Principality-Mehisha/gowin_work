onerror {quit -code 1 -f}
foreach test {tb_ws2812_tx tb_ws2812_16} {
    vsim -voptargs=+acc work.$test
    onfinish stop
    run -all
    if {[examine -radix unsigned /$test/passed] != 1} {
        quit -code 1 -f
    }
    quit -sim
}
quit -code 0 -f
