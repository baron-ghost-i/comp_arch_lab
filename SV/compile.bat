@echo off
set module=%1

iverilog -o output/%module%.out adders.sv %module%.sv %module%_tb.sv
vvp output/%module%.out