#Create a simulator object
set ns [new Simulator]

#Open files for recording
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Black

#Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Open the ALl trace file
set nt [open out.tr w]
$ns trace-all $nt

#Define a 'finish' procedure
proc finish {} {
        global ns nf nt f0 f1 f2
	$ns flush-trace
	close $nf
	close $nt
        #Close the output files
        close $f0
        close $f1
        close $f2
        #Call xgraph to display the results
	exec nam out.nam &
        exec xgraph out0.tr out1.tr out2.tr -geometry 1920x1080 &
        exit 0
}

#proc finish {} {
#        global ns nf
#        $ns flush-trace
#        #Close the NAM trace file
#        close $nf
#        #Execute NAM on the trace file
#        exec nam out.nam &
#        exit 0
#}

#Create four nodes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

#Create links between the nodes
$ns duplex-link $n1 $n2 10Mb 10ms RED
$ns duplex-link $n5 $n2 10Mb 10ms RED
$ns duplex-link $n2 $n3 10Mb 10ms RED
$ns queue-limit $n2 $n3 10
$ns queue-limit $n3 $n2 10
$ns duplex-link $n3 $n4 10Mb 10ms RED
$ns duplex-link $n3 $n6 10Mb 10ms RED

#Set RED Queue Parameters
#Queue/RED set gentle_ true
#Queue/RED set thresh_ 1
#Queue/RED set maxthresh_ 15
#Queue/RED set weight_ 10
#Queue/RED set setbit_ false

#Give node position (for NAM)
$ns duplex-link-op $n1 $n2 orient right-down
$ns duplex-link-op $n5 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n6 orient right-down

#Setup a TCP1 connection
set tcp1 [new Agent/TCP/Newreno]
$tcp1 set class_ 1
$ns attach-agent $n1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n4 $sink1
$ns connect $tcp1 $sink1
$tcp1 set fid_ 1

#Setup a FTP1 over TCP1 connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n5 $udp
set null [new Agent/Null]
$ns attach-agent $n6 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
#$cbr set interval_ 0.001
$cbr set packet_size_ 1000
$cbr set rate_ 9mb
$cbr set random_ false


proc record {} {
        global sink1 tcp1 f0 f1 f2 ftp1
        #Get an instance of the simulator
        set ns [Simulator instance]
        #Set the time after which the procedure should be called again
        set time 0.5
        #How many bytes have been received by the traffic sinks?
        set bw0 [$sink1 set bytes_]
        set bw1 [$sink1 set bytes_]
        set bw2 [$sink1 set bytes_]
        #Get the current time
        set now [$ns now]
        #Calculate the bandwidth (in MBit/s) and write it to the files
        puts $f0 "$now [expr $bw0/$time*8/1000000]"
        puts $f1 "$now [expr $bw1/$time*8/1000000]"
        puts $f2 "$now [expr $bw2/$time*8/1000000]"
        #Reset the bytes_ values on the traffic sinks
        $sink1 set bytes_ 0
        $sink1 set bytes_ 0
        $sink1 set bytes_ 0
        #Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}

#Schedule events for the CBR agents
$ns at 0.0 "record"
$ns at 0.0 "$ftp1 start"
$ns at 0.5 "$cbr start"
$ns at 4.5 "$cbr stop"
$ns at 4.5 "$ftp1 stop"



#Detach tcp and sink agents (not really necessary)
$ns at 4.6 "$ns detach-agent $n1 $tcp1 ; $ns detach-agent $n4 $sink1"


#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"


#Print CBR packet size and interval
puts "CBR packet size = [$cbr set packet_size_]"
puts "CBR interval = [$cbr set interval_]"

#Run the simulation
$ns run

