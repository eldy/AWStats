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
'/default.ida?',
'exe?/c+dir',
#'root.exe?/c',
#'cmd.exe?/c',
);


# WormsHashID
# Each Worms search ID is associated to a string that is unique name of worm.
#--------------------------------------------------------------------------
%WormsHashID	= (
'/default.ida?','code_red',
'exe?/c+dir','nimba'
#'root.exe?/c','nimba',
#'cmd.exe?/c','nimba'
#'/MSOffice/cltreq.asp'		# Not a worm, a check by IE to see if discussion bar is turned on
#'/_vti_bin/owssrv.dll'		# Not a worm, a check by IE to see if discussion bar is turned on
);


# WormsHashLib
# Worms name list ('worm unique id in lower case','worm clear text')
# Each unique ID string is associated to a label
#-------------------------------------------------------
%WormsHashLib   = (
'code_red','Code Red family worm',
'nimba','Nimba family worm'
);


1;
