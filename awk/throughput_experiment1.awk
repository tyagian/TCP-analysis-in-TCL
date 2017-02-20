BEGIN {

	n3 = "2";
	n4 = "3";
	n1_addr = "0.0"
	n4_addr = "3.0"
	tcp1_flow_id = 1;
	tcp1_flow_start_time = 0;
	tcp1_flow_end_time = 5;
	average_throughput_excluding_header = 0;
	average_throughput_including_header = 0;
	total_bits_sent_excluding_header = 0;
	total_bits_sent_including_header = 0;
	total_bits_for_goodput = 0;
	bits_per_byte = 8;
	header_size = 40; #IP header 20 + TCP header 20
	sampling_interval = 0.5
	sampling_last_index = int(tcp1_flow_end_time / sampling_interval) + 1;
	sampling_total_bits[0] = 0;

}

{

	EVENT = $1;
	TIME = $2;
	FROM_NODE = $3;
	TO_NODE = $4;
	PACKET_TYPE = $5;
	PACKET_SIZE = $6;
	FLOW_ID = $8;
	SRC_ADDR = $9;
	DEST_ADDR = $10;
	SEQ_NUMBER = $11;
	PACKET_ID = $12;

	if ("r" == EVENT && 
		"tcp" == PACKET_TYPE && 
		n3 == FROM_NODE &&
		n4 == TO_NODE && 
		n1_addr == SRC_ADDR &&
		n4_addr == DEST_ADDR &&
		tcp1_flow_id == FLOW_ID) 
	{
		bits_sent_excluding_header = (PACKET_SIZE - header_size) * bits_per_byte;
		total_bits_sent_excluding_header += bits_sent_excluding_header;

		bits_sents_including_header = PACKET_SIZE * bits_per_byte
		total_bits_sent_including_header += bits_sents_including_header;

		sampling_index = int(TIME / sampling_interval) + 1;
		sampling_total_bits[sampling_index] += bits_sent_excluding_header;

	}
}

END {

	#To prvent zero division
	if (tcp1_flow_end_time > tcp1_flow_start_time) 
	{
		average_throughput_excluding_header = total_bits_sent_excluding_header / (tcp1_flow_end_time - tcp1_flow_start_time) ;
		average_throughput_including_header = total_bits_sent_including_header / (tcp1_flow_end_time - tcp1_flow_start_time) ;
	}

	#printf ("%f\n", average_throughput_excluding_header);
	#printf ("%f\n", average_throughput_including_header);

	time_passed = 0;
	
	for( sampling_index = 0; sampling_index <= sampling_last_index; ++sampling_index)
	{
		printf ("%f %f\n",  time_passed, sampling_total_bits[sampling_index]);
		time_passed += sampling_interval;
	}
}
