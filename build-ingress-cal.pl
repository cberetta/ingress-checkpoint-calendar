#!/usr/bin/perl

# USAGE:
# perl build-ingress-cal.pl > ingress-checkpoint-calendar.ics

use DateTime;

# CONFIG: Date time of the FIRST cycle
my $CycleStartDate = DateTime -> new(
	year      => 2017,
	month     => 1,
	day       => 6,
	hour      => 3,
	minute    => 0,
	time_zone => 'Europe/Rome'
);

# CONFIG: How may cycle to generate
my $CycleToGenerate = 50;

my $CycleLen = 175;	# 175 Hours for every cycle
my $CheckPointLen = 5;	# 5 Hours between checkpoints

my $ics_head = "";
$ics_head .= "BEGIN:VCALENDAR\r\n";
$ics_head .= "PRODID:-//Beretta Costantino//Ingress Septicycle Calendar Generator 1.0//EN\r\n";
$ics_head .= "VERSION:2.0\r\n";
$ics_head .= "CALSCALE:GREGORIAN\r\n";
$ics_head .= "METHOD:PUBLISH\r\n";
$ics_head .= "X-WR-CALNAME:Ingress Checkpoints\r\n";
$ics_head .= "X-WR-TIMEZONE:Europe/Rome\r\n";
$ics_head .= "X-WR-CALDESC:A calendar with the Ingress Checkpoints. The calendar contains $CycleToGenerate cycle.\r\n";
$ics_head .= "BEGIN:VTIMEZONE\r\n";
$ics_head .= "TZID:Europe/Rome\r\n";
$ics_head .= "BEGIN:DAYLIGHT\r\n";
$ics_head .= "TZOFFSETFROM:+0100\r\n";
$ics_head .= "TZOFFSETTO:+0200\r\n";
$ics_head .= "TZNAME:CEST\r\n";
$ics_head .= "END:DAYLIGHT\r\n";
$ics_head .= "BEGIN:STANDARD\r\n";
$ics_head .= "TZOFFSETFROM:+0200\r\n";
$ics_head .= "TZOFFSETTO:+0100\r\n";
$ics_head .= "TZNAME:CET\r\n";
$ics_head .= "END:STANDARD\r\n";
$ics_head .= "END:VTIMEZONE\r\n";

my $ics_foot = "END:VCALENDAR";


print $ics_head;

$CycleStartDate->add(hours => -$CheckPointLen);

my $CycleNum=1;
for ($i=0; $i<$CycleToGenerate; $i++) {

	my $CheckPointNum=1;
	for ($j=0; $j<($CycleLen/$CheckPointLen); $j++) {

		$CycleStartDate->add(hours => $CheckPointLen);

		my $CycleEndDate = $CycleStartDate->clone();
		$CycleEndDate->add(minutes => 15);

		my $dtstart = $CycleStartDate->strftime("%Y%m%dT%H%M%S");
		my $dtyear  = $CycleStartDate->year();
		#my $dtend   = $CycleEndDate->strftime("%Y%m%dT%H%M%S");
		my $dtnow   = DateTime->now()->strftime("%Y%m%dT%H%M%SZ");

		# Build a unique ID for every VEVENT
		my $uid = "";
		$uid .= DateTime->now()->strftime("%Y%m%dT%H%M%SZ");
		$uid .= "-$dtyear-".sprintf("%02s",$CycleNum)."-".sprintf("%02s",$CheckPointNum);
		$uid .= "\@devnull\.it";

		# Build code for VEVENT
		my $ics_event = "";
		$ics_event .= "BEGIN:VEVENT\r\n";
		$ics_event .= "DTSTART;TZID=Europe/Rome:$dtstart\r\n";
		$ics_event .= "DTEND;TZID=Europe/Rome:$dtstart\r\n";
		$ics_event .= "DTSTAMP:$dtnow\r\n";
		$ics_event .= "UID:$uid\r\n";
		$ics_event .= "CLASS:PUBLIC\r\n";	# Public
		#$ics_event .= "CLASS:PRIVATE\r\n";	# Private
		$ics_event .= "DESCRIPTION:Checkpoint(".sprintf("%02s",$CheckPointNum).") $dtyear.".sprintf("%02s",$CycleNum)."\r\n";
		$ics_event .= "LOCATION:\r\n";
		$ics_event .= "SEQUENCE:1\r\n";
		$ics_event .= "STATUS:CONFIRMED\r\n";
		$ics_event .= "SUMMARY:CP(".sprintf("%02s",$CheckPointNum).") $dtyear.".sprintf("%02s",$CycleNum)."\r\n";
		#$ics_event .= "TRANSP:OPAQUE\r\n";	# Occupied
		$ics_event .= "TRANSP:TRANSPARENT\r\n";	# Available
		$ics_event .= "END:VEVENT\r\n";

		# Print code
		print $ics_event;

		# Increment CheckPoint count
		$CheckPointNum++;
	}

	$CycleNum++;
}

# Print Foot
print $ics_foot;



#EOF
