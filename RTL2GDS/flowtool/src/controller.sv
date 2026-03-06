/* 
 *	Controller module for DD onboarding.
 *	Manages reading from memory, performing additions, and writing results back to memory.
 *
 *	This module can and should be modified but do not change the interface.
*/
module controller import calculator_pkg::*;(
	// DO NOT MODIFY THESE PORTS
  	input  logic              clk_i,
    input  logic              rst_i,
  
  	// Memory Access
    input  logic [ADDR_W-1:0] read_start_addr,
    input  logic [ADDR_W-1:0] read_end_addr,
    input  logic [ADDR_W-1:0] write_start_addr,
    input  logic [ADDR_W-1:0] write_end_addr,
  
  	// Memory Controls
    output logic 						write,
	output logic 						read,
    output logic [ADDR_W-1:0]			w_addr,
    output logic [MEM_WORD_SIZE-1:0]	w_data,
    output logic [ADDR_W-1:0]			r_addr,
    input  logic [MEM_WORD_SIZE-1:0]	r_data,

  	// Buffer Control (1 = upper, 0, = lower)
    output logic buffer_control,
  
  	// These go into adder
  	output logic [DATA_W-1:0] op_a,
    output logic [DATA_W-1:0] op_b,

	// Carry input for adder
	output logic carry_in,	// Carry input to adder
	input  logic carry_out, // Carry output from adder
	
	// What is being stored in the buffer
    input  logic [MEM_WORD_SIZE-1:0] buff_result
  
); 

	// DO NOT MODIFY THIS BLOCK: Count how many cycles the controller has been active
	logic [31:0] cycle_count;
	always_ff @(posedge clk_i) begin
		if (rst_i)
			cycle_count <= 32'd0;
		else
			cycle_count <= cycle_count + 1'b1;
	end
	//=========================================================================
	// You can change anything below this line. There is a skeleton but feel
	// free to modify as much as you want.
	//=========================================================================

	// Declare state machine states
	/* cadence enum state_t */
    state_t state, next;
	/* cadence enum buffer_loc_t */
	buffer_loc_t buffer_loc;

	// Registers to hold read data for current and next reads
	logic [ADDR_W-1:0] r_ptr, w_ptr;
  	
	// Number registers
	logic [DATA_W-1:0] lwr_a, upr_a;
	logic [DATA_W-1:0] lwr_b, upr_b;

	// Carry register
	logic carry_reg;
	
	//Next state logic
	always_comb begin
		unique case (state)
			S_IDLE:      next = S_READ;  
			S_READ:	  	 next = S_READ2; 
			S_READ2:     next = S_ADD;  
			S_ADD:	  	 next = S_ADD2; 
			S_ADD2:	  	 next = S_WRITE; 
			S_WRITE:     next = (w_ptr == write_end_addr) ? S_END : S_READ;
			S_END:       next = S_END;
			default:     next = S_IDLE;
		endcase
	end

	// State register
	always_ff @(posedge clk_i) begin
		if (rst_i)
			state <= S_IDLE;
		else
			state <= next;
	end

	// Data path registers
	always_ff @(posedge clk_i) begin
		if (rst_i) begin
			r_ptr <= read_start_addr;
			w_ptr <= write_start_addr;
			{lwr_a, upr_a} <= {MEM_WORD_SIZE{1'b0}};
			{lwr_b, upr_b} <= {MEM_WORD_SIZE{1'b0}};
			carry_reg <= 1'b0;
		end
		else begin
			unique case (state)
				S_IDLE: begin
					r_ptr <= r_ptr;
					w_ptr <= w_ptr;
					{upr_a, lwr_a} <= {MEM_WORD_SIZE{1'b0}};
					{upr_b, lwr_b} <= {MEM_WORD_SIZE{1'b0}};
					carry_reg <= 1'b0;
				end
				S_READ: begin
					r_ptr <= r_ptr + 1'b1;
					w_ptr <= w_ptr;
					{upr_a, lwr_a} <= {upr_a, lwr_a};
					{upr_b, lwr_b} <= {upr_b, lwr_b};
					carry_reg <= 1'b0;
				end
				S_READ2: begin
					r_ptr <= r_ptr + 1'b1;
					w_ptr <= w_ptr;
					{upr_a, lwr_a} <= r_data;
					{upr_b, lwr_b} <= {upr_b, lwr_b};
					carry_reg <= 1'b0;
				end
				S_ADD: begin
					r_ptr <= r_ptr;
					w_ptr <= w_ptr;
					{upr_a, lwr_a} <= {upr_a, lwr_a};
					{upr_b, lwr_b} <= r_data;
					carry_reg <= carry_out;
				end
				S_ADD2: begin
					r_ptr <= r_ptr;
					w_ptr <= w_ptr;
					{upr_a, lwr_a} <= {MEM_WORD_SIZE{1'b0}};
					{upr_b, lwr_b} <= {MEM_WORD_SIZE{1'b0}};
					carry_reg <= 1'b0;
				end
				S_WRITE: begin
					r_ptr <= r_ptr;
					w_ptr <= w_ptr + 1'b1;
					{upr_a, lwr_a} <= {MEM_WORD_SIZE{1'b0}};
					{upr_b, lwr_b} <= {MEM_WORD_SIZE{1'b0}};
					carry_reg <= 1'b0;
				end
				S_END: begin
					r_ptr <= r_ptr;
					w_ptr <= w_ptr;
					{upr_a, lwr_a} <= {MEM_WORD_SIZE{1'b0}};
					{upr_b, lwr_b} <= {MEM_WORD_SIZE{1'b0}};
					carry_reg <= 1'b0;
				end
			endcase
		end
	end


	// Combinational output logic
	assign write      = (state == S_WRITE);
	assign read       = (state == S_READ) || (state == S_READ2);
	assign r_addr     = r_ptr;
	assign w_addr     = w_ptr;
	assign w_data     = buff_result;
	assign carry_in   = ((state == S_ADD) || (state == S_ADD2)) ? carry_reg : 1'b0;
	assign op_a       = (state == S_ADD)  ? lwr_a :
	                    (state == S_ADD2) ? upr_a : {DATA_W{1'b0}};
	assign op_b       = (state == S_ADD)  ? r_data[DATA_W-1:0] :
	                    (state == S_ADD2) ? upr_b : {DATA_W{1'b0}};
	assign buffer_loc = (state == S_ADD2) ? UPPER : LOWER;

	assign buffer_control = buffer_loc;
  endmodule
