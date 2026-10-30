onerror {quit -code 1 -f}
foreach test {tb_hc05_commands tb_hc05_test tb_hc05_nominal} {
    vsim -voptargs=+acc work.$test
    onfinish stop
    run -all
    if {[examine -radix unsigned /$test/passed] != 1} {quit -code 1 -f}
    quit -sim
}
quit -code 0 -f
