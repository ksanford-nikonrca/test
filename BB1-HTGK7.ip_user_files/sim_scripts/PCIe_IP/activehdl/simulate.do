onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+PCIe_IP -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.PCIe_IP xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {PCIe_IP.udo}

run -all

endsim

quit -force
