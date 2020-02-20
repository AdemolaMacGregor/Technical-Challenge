# Repo
Repo for Hosting Technical Challenge Script

This script is for retrieving, stroing and plotting datetime and sequence number data from latest validated ledger from Ripples API.

# HOW DOES THE SCRIPT WORK

Below are some background information about the script:

Scripting Language: Shell
Platform/Environment: Amazon Linux AMI (EC2 Cloud Instance)

Tools & Dependencies required:
	curL, awk, cat, sed, cut etc..
	gnuplot software
	jq (json filter)
	xauth
	Postman (for testing API before scripting)
	
The step by step actions carried out when the script are detailed below:

i.	Backup and delete of result from previous API request result from stored directory.

ii.	Declaration of all required input variables.

iii.	Parameterized User Entry with input validation for 
a.	Desired Polling interval in seconds (positive integer) for posting requests to http://s1.ripple.com:51234/.
b.	Desired Count of Polls (positive integer) for posting requests to http://s1.ripple.com:51234/.

iv.	API Request to http://s1.ripple.com:51234/ and filtering of json response for desired data (result.info.time & result.info.validated_ledger.seq). The request is in a “for loop” with respect to values entered for the Polling interval and Polling Count. The resulting data is saved to a file.

v.	Graph is plotted with gnuplot with axis set to auto. All required formats for datetime are set with reference to the exported data.

vi.	Average, Minimum and Maximum time differences between API calls are calculated from the response dataset after removal of records with duplicate sequence numbers and conversion of the timestamp to UNIX Epoch time. The result is then printed on the screen for convenience.
