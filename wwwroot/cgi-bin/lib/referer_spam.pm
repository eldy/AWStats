# AWSTATS REFERER SPAMMERS ADATABASE
#-------------------------------------------------------
# If you want to extend AWStats detection capabilities,
# you must add an entry in RefererSpamKeys
#-------------------------------------------------------
# $Revision$ - $Author$ - $Date$


#package AWSREFSPAMMERS;



# RefererSpamKeys
# This list is used to know which keywords to search for in referer URLs
# to find if hits comes from a referer spammers. If referer URLs has a
# cost higher or equal to 4
# key, cost
#-------------------------------------------------------
%RefererSpamKeys = (
'adult',1,
'anal',2,
'dick',1,
'erotic',2,			# erotic, erotica
'gay',2,
'lesbian',2
'free',1,
'porn',2,
'sex',2
);


1;
