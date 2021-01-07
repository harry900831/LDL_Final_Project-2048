`define RANGE 4

module main(clk, rst, up, down, left, right, state);
	input clk, rst, up, down, left, right;
	output [3 : 0] state;



endmodule


module rotate ();


endmodule


module merge(in, out);
	input [`RANGE * 4 - 1:0] in;
	output reg [`RANGE * 4 - 1 : 0] out;
	parameter zero = `RANGE'b0;
	wire [`RANGE - 1 : 0] arr[3 : 0];
	wire [3 : 0] type;

	assign {arr[3], arr[2], arr[1], arr[0]} = in;
	assign type = {arr[3] == zero, arr[2] == zero, arr[1] == zero, arr[0] == zero};

	always@(*) begin
		case (type)
			4'b0000: out = 0;
			4'b0001: out = in;
			4'b0010: out = {{3{zero}}, arr[1]};
			4'b0011:begin
						if(arr[0] == arr[1]) out = {{3{zero}}, arr[0] + `RANGE'b1};
						else out = {{2{zero}}, arr[1], arr[0]};
					end
			4'b0100: out = {{3{zero}}, arr[2]};
			4'b0101:begin
						if(arr[0] == arr[2]) out = {{3{zero}}, arr[0] + `RANGE'b1};
						else out = {{2{zero}}, arr[2], arr[0]};
					end
			4'b0110:begin
						if(arr[1] == arr[2]) out = {{3{zero}}, arr[1] + `RANGE'b1};
						else out = {{2{zero}}, arr[2], arr[1]};
					end
			4'b0111:begin
						if(arr[0] == arr[1]) out = {{2{zero}}, arr[2], arr[0] + `RANGE'b1};
						else if(arr[1] == arr[2]) out = {{2{zero}}, arr[1] + `RANGE'b1, arr[0]};
						else out = in;
					end
			4'b1000: out = {{3{zero}}, arr[3]};
			4'b1001:begin
						if(arr[0] == arr[3]) out = {{3{zero}}, arr[0] + `RANGE'b1};
						else out = {{2{zero}}, arr[3], arr[0]};
					end
			4'b1010:begin
						if(arr[1] == arr[3]) out = {{3{zero}}, arr[1] + `RANGE'b1};
						else out = {{2{zero}}, arr[3], arr[1]};
					end
			4'b1011:begin
						if(arr[0] == arr[1]) out = {{2{zero}}, arr[3], arr[0] + `RANGE'b1};
						else if(arr[1] == arr[3]) out = {{2{zero}}, arr[1] + `RANGE'b1, arr[0]};
						else out = {zero, arr[3], arr[1], arr[0]};
					end
			4'b1100:begin
						if(arr[2] == arr[3]) out = {{3{zero}}, arr[2] + `RANGE'b1};
						else out = {{2{zero}}, arr[3], arr[2]};
					end
			4'b1101:begin
						if(arr[0] == arr[1]) out = {{2{zero}}, arr[3], arr[0] + `RANGE'b1};
						else if(arr[2] == arr[3]) out = {{2{zero}}, arr[2] + `RANGE'b1, arr[0]};
						else out = {zero, arr[3], arr[2], arr[0]};
					end
			4'b1110:begin
						if(arr[1] == arr[2]) out = {{2{zero}}, arr[3], arr[1] + `RANGE'b1};
						else if(arr[2] == arr[3]) out = {{2{zero}}, arr[2] + `RANGE'b1, arr[1]};
						else out = {zero, arr[3], arr[2], arr[1]};
					end
			4'b1111:begin
						if(arr[0] == arr[1]) begin
							if(arr[1] == arr[2]) out = {{2{zero}}, arr[2] + `RANGE'b1, arr[0] + `RANGE'b1};
							else out = {zero, arr[3], arr[2], arr[1] + `RANGE'b1};
						end	else if(arr[1] == arr[2]) out = {zero, arr[3], arr[1] + `RANGE'b1, arr[0]};
						else if(arr[2] == arr[3])out = {zero, arr[2] + `RANGE'b1, arr[1], arr[0]};
						else out = in;
					end
			default: out = in;
		endcase
	end
endmodule
