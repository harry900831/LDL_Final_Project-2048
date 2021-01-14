module AI(clk, rst, state, board, best_dir);
    input clk, rst;
    input [63 : 0] board;
	input [2 : 0] state;
    output reg [2 : 0] best_dir;

    wire [35 : 0] up_point, down_point, left_point, right_point;
    
    parameter INPUT = 3'b000;
	parameter MERGE = 3'b001;
	parameter GEN = 3'b010;
	parameter CHECK = 3'b011;
	parameter END = 3'b100;
	parameter SEARCH = 3'b101;
    
    parameter UP = 3'b001;
	parameter DOWN = 3'b010;
	parameter LEFT = 3'b011;
	parameter RIGHT = 3'b100;

	wire start1, start2, start3, start4;
    wire [63 : 0] up_b, down_b, right_b, left_b, init_up, init_down, init_right, init_left;
    MoveUp mu(board, up_b);
	MoveDown md(board, down_b);
	MoveRight mr(board, right_b);
	MoveLeft ml(board, left_b);
    GenPlace genb1(clk, rst, up_b, init_up);
    GenPlace genb2(clk, rst, down_b, init_down);
	GenPlace genb3(clk, rst, right_b, init_right);
	GenPlace genb4(clk, rst, left_b, init_left);

	assign start1 = (state == INPUT);
	assign start2 = (state == INPUT);
	assign start3 = (state == INPUT);
	assign start4 = (state == INPUT);
	
	MakeMove mk1(clk, rst, start1, init_up, up_point);
	MakeMove mk2(clk, rst, start2, init_down, down_point);
	MakeMove mk3(clk, rst, start3, init_right, left_point);
	MakeMove mk4(clk, rst, start4, init_left, right_point);


	reg [20 : 0] count, next_count;
    always@(posedge clk) begin
        if(state == INPUT) begin
			count <= 21'd100000;
		end else count <= next_count;
    end


	always@(*) begin
		if(state == SEARCH) next_count = (count == 0 ? 0 : count - 1);
		else if(state == CHECK) next_count = 21'd7122;
		else next_count = count;		
	end
	always@(*) begin
		if(count < 21'd5)	begin
			if(up_point >= down_point && up_point >= left_point && up_point >= right_point) best_dir = UP;
			else if(down_point >= up_point && down_point >= left_point && down_point >= right_point) best_dir = DOWN;
			else if(left_point >= down_point && left_point >= up_point && left_point >= right_point) best_dir = LEFT;
			else if(right_point >= up_point && right_point >= left_point && right_point >= down_point) best_dir = RIGHT;
			else best_dir = 0;
		end else best_dir = 0;
	end

   

endmodule


module MakeMove(clk, rst, start, in, out);
	input clk, rst, start;
	input [63 : 0] in;
	output reg [35 : 0] out;

    parameter INPUT = 3'b000;
	parameter MERGE = 3'b001;
	parameter GEN = 3'b010;
	parameter CHECK = 3'b011;
	parameter END = 3'b100;
	parameter SEARCH = 3'b101;
	parameter INIT = 3'b110;
    
    parameter UP = 3'b001;
	parameter DOWN = 3'b010;
	parameter LEFT = 3'b011;
	parameter RIGHT = 3'b100;

    reg [35 : 0] next_out;
	reg [2 : 0] state, next_state, dir, next_dir;
	wire [3 : 0] get_rnd;
	reg [63 : 0] board, next_board;
	wire [25 : 0] sum;
	wire [3 : 0] arr [15 : 0];



	assign {arr[15], arr[14], arr[13], arr[12], arr[11], arr[10], arr[9], arr[8], arr[7], arr[6], arr[5], arr[4], arr[3], arr[2], arr[1], arr[0]} = board;

	assign sum = (((arr[15]+arr[14])+(arr[13]+arr[12]))+((arr[11]+arr[10])+(arr[9]+arr[8])))+(((arr[7]+arr[6])+(arr[5]+arr[4]))+((arr[3]+arr[2])+(arr[1]+arr[0])));



	MoveUp mu(board, up_board);
	MoveDown md(board, down_board);
	MoveRight mr(board, right_board);
	MoveLeft ml(board, left_board);
	GenPlace genb1(clk, rst, board, gen_board);
	RandGen4 rnd1(clk, rst, get_rnd);

	always@(posedge clk) begin
		if(start == 1) begin
			state <= INPUT;
			dir <= 3'b0;
			board <= in;
		end else begin
			state <= next_state;
			dir <= next_dir;
			board <= next_board;
		end
	end

	reg[10 : 0] count, next_count;
	always@(posedge clk) begin
		if(start == 1) begin
			count <= 11'd20;
		end else count <= next_count;
	end

	always@(posedge clk) begin
		if(start == 1) out <= 0;
		else out <= out + next_out;
	end

	always@(*) begin
		if(count == 0) next_count = 11'd20;
		else next_count = (state == CHECK ? count - 1 : count);
	end

	always@(*) begin
		if(state == INPUT) next_dir = 3'b001 + get_rnd % 4;
		else if (state == CHECK) next_dir = 3'b0;
		else if (state == INIT) next_dir = 3'b0;
		else next_dir = dir;
	end

	always@(*) begin
		next_out = 0;
		case(state)
			INIT: begin
				next_state = INPUT;
			end
			INPUT: begin
				if(next_dir != 3'b0) next_state = MERGE;
				else next_state = INPUT;
			end
			MERGE: begin
			     case(dir)
			         UP: next_state = (board == up_board ? SEARCH : GEN);
			         DOWN: next_state = (board == down_board ? SEARCH : GEN);
			         LEFT: next_state = (board == left_board ? SEARCH : GEN);
			         RIGHT: next_state = (board == right_board ? SEARCH : GEN);
			         default next_state = GEN;
			     endcase
			end
			SEARCH: next_state = CHECK;
			GEN: next_state = CHECK;
			CHECK: begin
				if(count == 0) begin
					next_state = INIT;
					next_out = sum;
				end
				else next_state = INPUT;
			end
			END: next_state = END;
			default: next_state = END;
		endcase
	end

	always@(*) begin
		if(state == INIT) board = in;
		if(state == MERGE) begin
			case(dir)
				UP: next_board =  up_board;
				DOWN: next_board =  down_board;
				LEFT: next_board =  left_board;
				RIGHT: next_board =  right_board;
				default: next_board =  board;
			endcase
		end else if(state == GEN) begin
		        next_board = gen_board;
		end else next_board = board;
	end

endmodule