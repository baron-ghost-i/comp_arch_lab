@echo off

IF "%4"=="" (
	IF "%3"=="" (
		IF "%2"=="" (
			iverilog -g2012 -o output/%1.out adders.sv %1.sv %1_tb.sv
		) ELSE (
			iverilog -g2012 -o output/%1.out adders.sv %1.sv %1_tb.sv %2.sv
		)
	) ELSE (
		iverilog -g2012 -o output/%1.out adders.sv %1.sv %1_tb.sv %2.sv %3.sv

	)
) ELSE (
		iverilog -g2012 -o output/%1.out adders.sv %1.sv %1_tb.sv %2.sv %3.sv %4.sv
)
vvp output/%1.out