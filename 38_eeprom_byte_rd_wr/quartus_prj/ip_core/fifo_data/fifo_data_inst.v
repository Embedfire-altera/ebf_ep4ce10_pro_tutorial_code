fifo_data	fifo_data_inst (
	.clock ( clock_sig ),
	.data ( data_sig ),
	.rdreq ( rdreq_sig ),
	.wrreq ( wrreq_sig ),
	.empty ( empty_sig ),
	.full ( full_sig ),
	.q ( q_sig ),
	.usedw ( usedw_sig )
	);
