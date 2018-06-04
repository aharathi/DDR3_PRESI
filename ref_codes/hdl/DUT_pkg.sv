//////////////////////////////////////////////////////////////////////////////
// DUT_pkg.sv : PACKAGE declarion file
//
// Author:			Sai Teja , Suraj Avinash , Tejas Chavan
// Version:			1.1
// Last modified:	15-Mar-2018
// 
//  Package containing the parameterized definitions of TIMING and WIDTHS 
//
/////////////////////////////////////////////////////////////////////////////


package DDR3MemPkg;

	// BIT Parameters
	parameter DM_BITS          =       1; // Set this parameter to control how many Data Mask bits are used
	parameter ADDR_BITS        =      14; // MAX Address Bits
	parameter BA_BITS          =       3; // MAX Address Bits
	parameter ROW_BITS         =      14; // Set this parameter to control how many Address bits are used
	parameter COL_BITS         =      10; // Set this parameter to control how many Column bits are used
	parameter DQ_BITS          =       8; // Set this parameter to control how many Data bits are used       **Same as part bit width**
	parameter DQS_BITS         =       1; // Set this parameter to control how many Dqs bits are used
	parameter BURST_L	   	   =	   8; // Burst Length
	parameter ADDR_MCTRL	   =	  32; // Address to the Controller
    parameter T_WL = 8;
	
	// Memory Parameters for Configurations
	parameter T_RAS	 =15;	// From Row Addr to Precharge
	parameter T_RCD	 =6;	// Row to Column Delay
	parameter T_CL	 =6;	// Column to Data Delay
	parameter T_RC	 =21;	// RP to Next RP Delay
	parameter T_BL	 =4;	// Burst Length in cycles
	parameter T_RP	 =6;	// Precharge Time
	parameter T_MRD	 =4;	// Precharge Time
	
	// FSM States for the DDR3
	typedef enum logic [3:0] { RESET,POWERUP, MRLOAD, ZQ_CAL, CAL_DONE, IDLE, ACT, READ, WRITE, WBURST, RBURST, AUTORP, DONE} States; 

	States state;			// Handler of Enum: States

endpackage
