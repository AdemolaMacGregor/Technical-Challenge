#!/bin/sh
#Backup & Delete Old Output File
mkdir -p /tmp/xrpledger
mkdir -p /tmp/xrpledger/result
mkdir -p /tmp/xrpledger/backup
[ -f "/tmp/xrpledger/result/output.csv" ] && mv "/tmp/xrpledger/result/output.csv" /tmp/xrpledger/backup/output-$(date -d "today" +"%Y%m%d%H%M")
rm -rf /tmp/xrpledger/result/*.csv


#Declare Variables
output="/tmp/xrpledger/result/output.csv"
result="/tmp/xrpledger/result/result.csv"
date="/tmp/xrpledger/result/date.csv"
clean="/tmp/xrpledger/result/clean.csv"
epoch="/tmp/xrpledger/result/epoch.csv"
diff="/tmp/xrpledger/result/diff.csv"
avemaxmin="/tmp/xrpledger/result/avemaxmin.csv"


#Enter Desired Interval and Count
#Interval = Difference between Polling times in one Polling set
#Count = Number of Poll points required
printf "\n"
printf "<<<<<<<<<<<RIPPLE: VALIDATED LEDGER VS TIME COMPARISON>>>>>>>>>>\n"
printf "\n"
echo -n Enter Desired Polling Interval in Seconds [INTEGER]:
read interval
if ! [[ "$interval" =~ ^[0-9]+$ ]]
    then
        echo "Ooops! Accepting Integers Only!! Please Rerun the Program!!!"
	exit 1;
fi

echo -n Enter Desired Count of Polls [INTEGER]:
read count
if ! [[ "$count" =~ ^[0-9]+$ ]]
    then
        echo "Ooops! Accepting Integers Only!! Please Rerun the Program!!!"
        exit 1;
fi
printf "\n"


#Ripple API Call
for ((i=1; i<=$count; i++))
do
	curl -# -H "Content-type: application/json" -d '{"method": "server_info","params": [{}]}' 'http://s1.ripple.com:51234/' | jq -r '[.result | .info.time, .info.validated_ledger.seq] | @tsv' >> $output
	sleep $interval
done


#Generate Graph for Result
gnuplot -persist <<-EOFMarker
	# grid
	set grid
	#ranges
	set autoscale x
	set autoscale y
	#title and labels
	set title 'VALIDATED LEDGERS TIME - SEQ GRAPH'           # plot title
	set xlabel 'Time'                                        # x-axis label
	set ylabel 'SequenceNumber'                              # y-axis label
	#datetime formats
	set xdata time
	set timefmt "%Y-%b-%d %H:%M"
	set format x "%m/%d"
	set timefmt "%Y-%b-%d %H:%M:%S"
	plot "/tmp/xrpledger/result/output.csv" using 1:3 with linespoint
EOFMarker
printf "\n"


# Minimum, Maximum and Average Calculator
# BONUS SECTION
awk '!a[$3]++' $output	> $clean		#Remove duplicates records with same sequence number
cut -c 13-28 $clean > $date			#Extract dates from output file
while read p; do
	date -d "$p" +%s >> $epoch					#Convert dates to Epoch
done < $date
awk 'NR>1{print $1-p} {p=$1}' $epoch > $diff 	#Calculate difference between list of numbers from a file [duplicate]
awk '{ total += $1; count++ } END { print total/count }' $diff >> $avemaxmin #Calculate the average
awk 'BEGIN{a=   0}{if ($1>0+a) a=$1} END{print a}' $diff >> $avemaxmin #Calculate the maximum
awk 'BEGIN{a=1000}{if ($1<0+a) a=$1} END{print a}' $diff >> $avemaxmin #Calculate the minimum
printf "\n"
printf "<<<<<<<<<<<THE AVERAGE, MAXIMUM AND MINIMUM TIME TAKEN FOR NEW LEDGER TO BE VALIDATED ARE BELOW>>>>>>>>>>\n"
cat /tmp/xrpledger/result/avemaxmin.csv
printf "\n"
printf "Graph will be displayed shortly.....\n"
printf "\n"
