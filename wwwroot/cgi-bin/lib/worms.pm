# AWSTATS WORMS ADATABASE
#-------------------------------------------------------
# If you want to add worms to extend AWStats database detection capabilities,
# you must add an entry in WormsSearchIDOrder, WormsHashID and WormsHashLib.
#-------------------------------------------------------
# $Revision$ - $Author$ - $Date$


#package AWSWORMS;



# WormsSearchIDOrder
# This list is used to know in which order to search Robot IDs.
# This array is array of Worms matching criteria found in URL submitted
# to web server.
#-------------------------------------------------------
@WormsSearchIDOrder = (
'\/default\.ida',
'\/null\.idq',
'exe\?\/c\+dir',
'root\.exe',
'Admin\.dll',
'Admin\.dll',
'\/winnt\/system32\/cmd\.exe',
'\/_vti_inf\.html',
'\/_vti_bin\/shtml\.exe\/_vti_rpc'
);

# WormsHashID
# Each Worms search ID is associated to a string that is unique name of worm.
#--------------------------------------------------------------------------
%WormsHashID = (
'\/default\.ida','code_red',
'\/null\.idq','code_red',
'exe\?\/c\+dir','nimba',
'root\.exe','nimba',
'Admin\.dll','nimba',
'Admin\.dll','nimba',
'\/winnt\/system32\/cmd\.exe','nimba',
'\/_vti_inf\.html','unknown',
'\/_vti_bin\/shtml\.exe\/_vti_rpc','unknown'
#'/MSOffice/cltreq.asp'		# Not a worm, a check by IE to see if discussion bar is turned on
#'/_vti_bin/owssrv.dll'		# Not a worm, a check by IE to see if discussion bar is turned on
);

# WormsHashLib
# Worms name list ('worm unique id in lower case','worm clear text')
# Each unique ID string is associated to a label
#-------------------------------------------------------
%WormsHashLib = (
'code_red','Code Red family worm',
'nimba','Nimba family worm',
'unknown','Unknown worm'
);

1;
