# AWSTATS WORMS ADATABASE
#-----------------------------------------------------------------------------
# If you want to add worms to extend AWStats database detection capabilities,
# you must add an entry in WormsSearchIDOrder, WormsHashID and WormsHashLib.
#-----------------------------------------------------------------------------


#package AWSWORMS;



# WormsSearchIDOrder
# This list is used to know in which order to search Worm IDs.
# This array is array of Worms matching criteria found in URL submitted
# to web server. This is a not case sensitive ID.
#-----------------------------------------------------------------------------
@WormsSearchIDOrder = (
'\/default\.ida',
'\/null\.idq',
'exe\?\/c\+dir',
'root\.exe',
'admin\.dll',
'\/nsiislog\.dll',
'\/sumthin',
'\/winnt\/system32\/cmd\.exe',
'\/_vti_inf\.html',
'\/_vti_bin\/shtml\.exe\/_vti_rpc'
);

# WormsHashID
# Each Worms search ID is associated to a string that is unique name of worm.
#-----------------------------------------------------------------------------
%WormsHashID = (
'\/default\.ida','code_red',
'\/null\.idq','code_red',
'exe\?\/c\+dir','nimda',
'root\.exe','nimda',
'admin\.dll','nimda',
'\/nsiislog\.dll','mpex',
'\/sumthin','sumthin',
'\/winnt\/system32\/cmd\.exe','nimda',
'\/_vti_inf\.html','unknown',
'\/_vti_bin\/shtml\.exe\/_vti_rpc','unknown'
#'/MSOffice/cltreq.asp'		# Not a worm, a check by IE to see if discussion bar is turned on
#'/_vti_bin/owssrv.dll'		# Not a worm, a check by IE to see if discussion bar is turned on
);

# WormsHashLib
# Worms name list ('worm unique id in lower case','worm clear text')
# Each unique ID string is associated to a label
#-----------------------------------------------------------------------------
%WormsHashLib = (
'code_red','Code Red family worm',
'mpex','IIS Exploit worm',
'nimda','Nimda family worm',
'sumthin','Sumthin worm',
'unknown','Unknown worm'
);

# WormsHashTarget
# Worms target list ('worm unique id in lower case','worm target clear text')
# Each unique ID string is associated to a target
#-----------------------------------------------------------------------------
%WormsHashTarget = (
'code_red','IIS',
'mpex','IIS',
'nimda','IIS',
'sumthin','?',
'unknown','MS products',
);

1;
