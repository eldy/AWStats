#!/usr/bin/perl
# Usage:
# 1- Copy the robot list 1 in this file
# 2- Downlaod robot file and rename it all.txt
# 3- Launch script

$FILENAME="all.txt";

# Robots to remove of AWStats database
%REMOVE=(
'webs'=>1,
'tcl'=>1,
'wget'=>2
);
# Robots to transcode for using in AWStats database
%TRANSCODE=(
'directhit'=>'direct_hit',
'calif'=>'calif[^r]',
'fish'=>'[^a]fish',
'roadrunner'=>'road_runner',
'lycos'=>'lycos_',
'voyager'=>'^voyager\/'
);



@RobotsSearchIDOrder_list1 = (
'antibot',
'appie',
'architext',
'bjaaland',
'digout4u',
'echo',
'fast\-webcrawler',
'ferret',
'googlebot',
'gulliver',
'harvest',
'htdig',
'ia_archiver',
'askjeeves',
'jennybot',
'linkwalker',
'lycos_',
'mercator',
'moget',
'muscatferret',
'myweb',
'netcraft',
'nomad',
'petersnews',
'scooter',
'slurp',
'unlost_web_crawler',
'voila',
'^voyager\/',		# Add ^ and \/ to avoid to exclude voyager and amigavoyager browser
'webbase',
'weblayers',
'wisenutbot'
);

@reported=(
# Other robots reported by users
'aport',
'awbot',
'baiduspider',
'bobby',
'boris',
'bumblebee',
'cscrawler',
'daviesbot',
'exactseek',
'ezresult',
'gigabot',
'gnodspider',
'grub',
'henrythemiragorobot',
'holmes',
'internetseer',
'justview',
'linkbot',
'metager\-linkchecker',	# Must be before linkchecker
'linkchecker',
'microsoft_url_control',
'msiecrawler',
'nagios',
'perman',
'pompos',
'rambler',
'redalert',
'shoutcast',
'slysearch',
'surveybot',
'turnitinbot',
'turtlescanner',		# Must be before turtle
'turtle',
'ultraseek',
'webclipping\.com',
'webcompass',
'yahoo\-verticalcrawler',
'yandex',
'zealbot',
'zyborg'
);


# Read robot file and build output

open(FILE,"<$FILENAME") || die "Error opening file $FILENAME";
my $robotname=$robotid="";
while (<FILE>) {
	my $line=$_;
	if ($line =~ /robot-id[:|](\s*)([^\s]+)(\s*)$/i) {
		$robotid=lc($2);
		$robotid =~ s/^\s+//;
		$robotid =~ s/\s+$//;
        $robotid=quotemeta($robotid);
        $robotid=$TRANSCODE{$robotid}?$TRANSCODE{$robotid}:$robotid;
	}
	if ($line =~ /robot-name[:|](\s*)(.*)/i) {
		$robotname=$2;
		$robotname =~ s/^\s+//;
		$robotname =~ s/\s+$//;
		if ($robotid && $robotname) {
		    if (length($robotid)<=3) { next; }
            if ($REMOVE{$robotid}) { next; }		    
			$robot{$robotid}=$robotname;
			$robotname=$robotid='';
		}
	}
}
close(FILE);

# Common robots
print "\n# Common robots (In robot file)\n";
foreach my $rob (@RobotsSearchIDOrder_list1) {
    if ($robot{$rob}) {
        print "'$rob',\n";
        $robotout{$rob}=1;
    }
}
# Other robots in robot list (less common)
print "\n# Less common robots (In robot file)\n";
foreach my $rob (sort keys %robot) {
    if (! $robotout{$rob}) { print "'$rob',\n"; }
}

print "\n";

# Common robots
print "\n# Common robots (In robot file)\n";
foreach my $rob (@RobotsSearchIDOrder_list1) {
    if ($robot{$rob}) {
        print "'$rob','$robot{$rob}',\n";
        $robotout{$rob}=1;
    }
}
# Other robots in robot list (less common)
print "\n# Less common robots (In robot file)\n";
foreach my $rob (sort keys %robot) {
    if (! $robotout{$rob}) { print "'$rob','$robot{$rob}',\n"; }
}



# Robot reported by users in AWStats that are now in official robot list
print "\n# Robot reported by users in AWStats that are now in official robot list\n";
foreach my $rob (@reported) {
    if ($robot{$rob}) {
        print "'$rob'\n";
    }
}
