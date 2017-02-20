BEGIN {
	n1 = "0";
	n2 = "1";
	n3 = "2";
	n4 = "3";
	n1_addr = "0.0";
	n4_addr = "3.0";
	tcp1_flow_id = 1;
	packet_sent = 0;
	packet_received = 0;
	packet_dropped = 0;
	drop_rate = 0;
	drop_rate2 = 0;

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
		++packet_sent;
	}

	if ("r" == EVENT && 
		"tcp" == PACKET_TYPE && 
		n3 == FROM_NODE &&
		n4 == TO_NODE && 
		n1_addr == SRC_ADDR &&
		n4_addr == DEST_ADDR &&
		tcp1_flow_id == FLOW_ID) 
	{
		++packet_received;
	}

	if ("d" == EVENT && 
	    tcp1_flow_id == FLOW_ID )
	{
		++packet_dropped;
	}
}

END {

	#To prvent zero division
	if ("0" != packet_sent) 
	{
		drop_rate = packet_dropped / packet_sent;
		drop_rate2 = (packet_sent - packet_received) / packet_sent;
	}

	printf ("%f\n", drop_rate);
	#printf ("%f\n", drop_rate2);
}
