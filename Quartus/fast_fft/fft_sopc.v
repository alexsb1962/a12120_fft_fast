module fft_sopc(
	clk,
	reset_n,
	sink_valid,
	sink_sop,
	sink_eop,
	sink_data,
	sink_error,
	source_ready,
	sink_ready,
	source_error,
	source_sop,
	source_eop,
	source_valid,
	source_data);


	input		clk;
	input		reset_n;
	input		sink_valid;
	input		sink_sop;
	input		sink_eop;
	input	[31:0]	sink_data;
	input	[1:0]	sink_error;
	input		source_ready;
	output		sink_ready;
	output	[1:0]	source_error;
	output		source_sop;
	output		source_eop;
	output		source_valid;
	output	[37:0]	source_data;


	fft	fft_inst(
		.clk(clk),
		.reset_n(reset_n),
		.inverse(0),
		.sink_valid(sink_valid),
		.sink_sop(sink_sop),
		.sink_eop(sink_eop),
		.sink_real(sink_data[15:0]  ),
		.sink_imag(sink_data[31:16] ),
		.sink_error(sink_error),
		.source_ready(source_ready),
		.sink_ready(sink_ready),
		.source_error(source_error),
		.source_sop(source_sop),
		.source_eop(source_eop),
		.source_valid(source_valid),
		.source_exp(source_data[5:0] ),
		.source_real(source_data[21:6] ),
		.source_imag(source_data[37:22] )
   );

endmodule
