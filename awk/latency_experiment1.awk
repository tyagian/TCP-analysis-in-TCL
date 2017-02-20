BEGIN {

	n1 = "0";
	n2 = "1";
	n1_addr = "0.0"
	n4_addr = "3.0"
	tcp1_flow_id = 1;
	total_delays  =0;
	average_delays = 0;
	packet_counts = 0;


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

	if ("+" == EVENT && 
		"tcp" == PACKET_TYPE && 
		n1 == FROM_NODE &&
		n2 == TO_NODE && 
		n1_addr == SRC_ADDR &&
		n4_addr == DEST_ADDR &&
		tcp1_flow_id == FLOW_ID) 
        {
		SendTime[SEQ_NUMBER] = TIME;
	}

	if ("r" == EVENT && 
		"ack" == PACKET_TYPE && 
		n1 == TO_NODE && 
		n2 == FROM_NODE &&
		n4_addr == SRC_ADDR &&
		n1_addr == DEST_ADDR &&
		tcp1_flow_id == FLOW_ID) 
       {
		ReceiveTime[SEQ_NUMBER] = TIME;

		if( ReceiveTime[SEQ_NUMBER] > SenTime[SEQ_NUMBER])
		{
			end_to_end_delays = ReceiveTime[SEQ_NUMBER] - SendTime[SEQ_NUMBER];
			++packet_counts;
			printf( "%d %f\n", packet_counts, end_to_end_delays);
			
			total_delays += end_to_end_delays;
		}
	}
}

END {

	#To prvent zero division
	if ("0" != packet_counts) 
	{
		average_delays = total_delays / packet_counts;
	}

	#printf (average_delays "\n");
}
