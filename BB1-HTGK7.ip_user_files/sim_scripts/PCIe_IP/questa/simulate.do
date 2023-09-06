onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib PCIe_IP_opt

do {wave.do}

view wave
view structure
view signals

do {PCIe_IP.udo}

run -all

quit -force
