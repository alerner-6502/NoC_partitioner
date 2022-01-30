module seg7_encoder	(
	input	    [3:0]	i_dig,
	output reg	[6:0]	o_seg
);

	always@(i_dig) begin
		case(i_dig)
			4'h0: o_seg = 7'b1000000;
			4'h1: o_seg = 7'b1111001;	// ---t----
			4'h2: o_seg = 7'b0100100; 	// |	  |
			4'h3: o_seg = 7'b0110000; 	// lt	 rt
			4'h4: o_seg = 7'b0011001; 	// |	  |
			4'h5: o_seg = 7'b0010010; 	// ---m----
			4'h6: o_seg = 7'b0000010; 	// |	  |
			4'h7: o_seg = 7'b1111000; 	// lb	 rb
			4'h8: o_seg = 7'b0000000; 	// |	  |
			4'h9: o_seg = 7'b0011000; 	// ---b----
			4'ha: o_seg = 7'b0001000;
			4'hb: o_seg = 7'b0000011;
			4'hc: o_seg = 7'b1000110;
			4'hd: o_seg = 7'b0100001;
			4'he: o_seg = 7'b0000110;
			4'hf: o_seg = 7'b0001110;
		endcase
	end

endmodule
