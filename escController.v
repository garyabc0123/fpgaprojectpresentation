module topmodule(clk,
				 u_up, u_down, v_up, v_down, w_up, w_down , 
				 buttom_up , buttom_down , reset,
				 oSEG0,oSEG1,oSEG2,oSEG3);
input clk;
input buttom_up,buttom_down;
input reset;
output u_up, u_down, v_up, v_down, w_up, w_down;
output	[6:0]	oSEG0,oSEG1,oSEG2,oSEG3;

wire [16:0] speed;
reg [8:0] volta;
wire nextclk;
wire secondclk;
wire slowpwm;
parameter stop_state = 0;
parameter start_state_1 = 1;
parameter stop_state_1 = 2;
parameter start_state_2 = 3;
parameter stop_state_2 = 4;
parameter start_state_3 = 5;
parameter stop_state_3 = 6;
parameter start_state_4 = 7;
parameter stop_state_4 = 8;
parameter start_state_5 = 9;
parameter stop_state_5 = 10;
parameter start_state_6 = 11;
parameter stop_state_6 = 12;
reg [4:0] current_state;
reg [4:0] next_state;
reg u_up_inline, u_down_inline, v_up_inline, v_down_inline, w_up_inline, w_down_inline;
/*
assign u_up = u_up_inline;
assign u_down = u_down_inline;
assign v_up = v_up_inline;
assign v_down = v_down_inline;
assign w_up = w_up_inline;
assign w_down = w_down_inline;
*/
assign u_down = u_down_inline;
assign v_down = v_down_inline;
assign w_down = w_down_inline;

initial begin
    
    volta = 8'hC0;
    current_state = stop_state;
	next_state = stop_state;
end
nextStateClock nextstateclock(clk,speed,nextclk);
secondGen secondgen(clk,secondclk);
scanbuttom scanb(secondclk,buttom_up,buttom_down,speed , reset);
pwmslowclock ppwmslowclock(clk,slowpwm);
voltaconvert vc_u(u_up_inline,u_up,volta,slowpwm);
voltaconvert vc_w(w_up_inline,w_up,volta,slowpwm);
voltaconvert vc_v(v_up_inline,v_up,volta,slowpwm);
SEG7_LUT_4 LEDOUT(	oSEG0,oSEG1,oSEG2,oSEG3,speed );
//finite state machine
always@(posedge nextclk ) begin
    if(speed == 0) begin
        current_state <= stop_state;
    end
    else begin
        current_state <= next_state;
    end
end
always@(current_state or nextclk) begin
    next_state = current_state + 1;
    if(next_state > start_state_6) begin
        next_state = stop_state;
    end
end
always@(current_state or nextclk) begin
    case(current_state)
        stop_state:begin
                    u_up_inline <= 0;
                    u_down_inline <= 0;
                    v_up_inline <= 0;
                    v_down_inline <= 0;
                    w_up_inline <= 0;
                    w_down_inline <= 0;
                    end
        start_state_1:begin
                    u_up_inline <= 1;
                    w_down_inline <= 1;
                    u_down_inline <= 0;
                    v_up_inline <= 0;
                    v_down_inline <= 0;
                    w_up_inline <= 0;
                    end
        start_state_2:begin
                    u_up_inline <= 1;
                    v_down_inline <= 1;
                    u_down_inline <= 0;
                    v_up_inline <= 0;
                    w_up_inline <= 0;
                    w_down_inline <= 0;
                    end
        start_state_3:begin
                    w_up_inline <= 1;
                    v_down_inline <= 1;
                    u_up_inline <= 0;
                    u_down_inline <= 0;
                    v_up_inline <= 0;
                    w_down_inline <= 0;
                    end
        start_state_4:begin
                    w_up_inline <= 1;
                    u_down_inline <= 1;
                    u_up_inline <= 0;
                    v_up_inline <= 0;
                    v_down_inline <= 0;
                    w_down_inline <= 0;
					end
        start_state_5:begin
                    v_up_inline <= 1;
                    u_down_inline <= 1;
                    u_up_inline <= 0;
                    v_down_inline <= 0;
                    w_up_inline <= 0;
                    w_down_inline <= 0;
					end
        start_state_6:begin
                    v_up_inline <= 1;
                    w_down_inline <= 1;
                    u_up_inline <= 0;
                    u_down_inline <= 0;
                    v_down_inline <= 0;
                    w_up_inline <= 0;
                    end
        default:begin
					u_up_inline <= 0;
                    u_down_inline <= 0;
                    v_up_inline <= 0;
                    v_down_inline <= 0;
                    w_up_inline <= 0;
                    w_down_inline <= 0;
    
					end
    endcase
end
endmodule


module nextStateClock(clk, speed, nextclk);

    //clk 1 second = 50000000
    //motor 6 status = 1 rad
    //count every 8333333 time
    input clk;
    input [16:0]speed;
    output reg nextclk;
    reg [32:0] times;
    initial begin
        times = 32'h0;
        nextclk = 1;
    end
    always@(posedge clk) begin
        times = times + 1;
        if(times * speed * 6 > 25000000) begin
            times <= 32'h0;
            nextclk = ~nextclk;
        end
        if(speed == 0) begin
			nextclk = ~nextclk;
		end

    end
endmodule
module voltaconvert(inline,outline,volta,clk);
	input inline,clk;
	input [8:0] volta;
	
	output outline;
	assign outline = inline;
		/*

	output reg outline;
	parameter state_0 = 0;
	parameter state_1 = 1;
    reg current_state;
    reg next_state;
    reg [16:0] counter;
    initial begin
        current_state = state_0;
        next_state = state_0;
        counter = 0;
    end

	always@(posedge clk) begin
        counter <= counter + 1;
		if(inline == 0 | volta == 0) begin
			current_state <= state_0;
		
		end
		else 
            current_state <= next_state;

        case(current_state)
            state_1:begin
                if(counter > volta) begin
                    next_state <= state_0;
                    counter <= 0;
                end
                
            end
            state_0:begin
                if(counter > (8'hFF - volta)) begin
                    next_state <= state_1;
                    counter <= 0;
                end
                
            end
        endcase

    end

    always@(current_state) begin
        case(current_state)
           state_0:
              outline = 0;
           state_1:
               outline = 1;
        endcase
    end
   
            
		*/	
		
endmodule

module pwmslowclock(in,out);
	input in;
	output reg out;
	reg [16:0] counter;
	initial begin
		out = 1;
		counter = 0;
	end
	always@(posedge in) begin
		counter = counter + 1;
		if(counter > 25000) begin
			counter = 0;
			out = ~out;
		end
	end
endmodule

module secondGen(clk,secondclk); //half
	input clk;
	output reg secondclk;
	reg [32:0] times;
	initial begin
		times = 32'h0;
		secondclk = 1;
	end
	always@(posedge clk) begin
		times = times + 1;
		if(times > 10000000) begin
			times <= 32'h0;
			secondclk = ~secondclk;
		end
	end
endmodule

module scanbuttom(secondclk,buttom_up,buttom_down,speed , reset);
	input secondclk,buttom_up,buttom_down,reset;
	output reg [16:0] speed;
	initial begin
		speed = 'h0080;
	end
	always@(posedge secondclk )begin
		if(!buttom_up & (speed < 'h2710)) begin //10000rpm
			speed = speed + 10;
		end
		else if(!buttom_down & (speed != 0)) begin
			speed = speed - 1;
		end
		else if(~reset) begin
			speed = 0;
		end
		else
			speed = speed;
	end
endmodule 

module SEG7_LUT_4 (	oSEG0,oSEG1,oSEG2,oSEG3,iDIG );
	input	[15:0]	iDIG;
	output	[6:0]	oSEG0,oSEG1,oSEG2,oSEG3;


	SEG7_LUT	u0	(	oSEG0,iDIG[3:0]	);
	SEG7_LUT	u1	(	oSEG1,iDIG[7:4]	);
	SEG7_LUT	u2	(	oSEG2,iDIG[11:8]	);
	SEG7_LUT	u3	(	oSEG3,iDIG[15:12]	);

endmodule

module SEG7_LUT	(	oSEG,iDIG	);
input	[3:0]	iDIG;
output	[6:0]	oSEG;

reg		[6:0]	oSEG;


always @(iDIG)
begin
		case(iDIG)
		4'h1: oSEG = 7'b1111001;	// ---t----
		4'h2: oSEG = 7'b0100100; 	// |	  |
		4'h3: oSEG = 7'b0110000; 	// lt	 rt
		4'h4: oSEG = 7'b0011001; 	// |	  |
		4'h5: oSEG = 7'b0010010; 	// ---m----
		4'h6: oSEG = 7'b0000010; 	// |	  |
		4'h7: oSEG = 7'b1111000; 	// lb	 rb
		4'h8: oSEG = 7'b0000000; 	// |	  |
		4'h9: oSEG = 7'b0011000; 	// ---b----
		4'ha: oSEG = 7'b0001000;
		4'hb: oSEG = 7'b0000011;
		4'hc: oSEG = 7'b1000110;
		4'hd: oSEG = 7'b0100001;
		4'he: oSEG = 7'b0000110;
		4'hf: oSEG = 7'b0001110;
		4'h0: oSEG = 7'b1000000;
		endcase
end


endmodule
