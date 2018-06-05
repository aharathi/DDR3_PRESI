/// testbench components ///

package ddr3_tb_pkg;

`include "uvm_macros.svh";
 import uvm_pkg::*;


typedef enum {DESELECT,NOP,ZQ_CAL_L,ZQ_CAL_S,ACTIVATE,READ,WRITE,PRECHARGE,REFRESH,SELF_REFRESH,DLL_DIS,MSR} command_t;

typedef bit [ROW_BITS-1:0] row_t;
typedef bit [BA_BITS-1:0] bank_t;
typedef bit [COL_BITS-1:0] column_t;

typedef bit [DQ_BITS-1:0] data_t;

typedef bit [ADDR_BITS-1:0] bus_addr_t;

typdef struct packed {bank_t ba,bus_addr_t} cfg_mode_reg_t;

typedef struct packed {row_t row,bank_t bank,column_t column} proc_addr_t;




endpackage  
