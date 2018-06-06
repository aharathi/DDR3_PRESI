



all : clean lib build run extract 

lib :
	vlib work
	vmap work work 

build :
	vlog -mfcu -f rtl.f -f tb.f +cover=bcesfx

run :
	vsim -c -novopt -cover ddr3_hvl_top +UVM_TESTNAME=$(TEST) $(EXTRA) -do "run -all;coverage save -onexit ddr3_cov.ucdb;exit"

extract :
	vcover report -details -html ddr3_cov.ucdb

clean:
	rm -rf work ddr3_cov.ucdb covhtmlreport 

