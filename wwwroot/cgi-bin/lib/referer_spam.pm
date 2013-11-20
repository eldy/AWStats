# AWSTATS REFERER SPAMMERS ADATABASE
#-------------------------------------------------------
# If you want to extend AWStats detection capabilities,
# you must add an entry in RefererSpamKeys
#-------------------------------------------------------


#package AWSREFSPAMMERS;



# RefererSpamKeys
# This list is used to know which keywords to search for in referer URLs
# to find if hits comes from a referer spammers. If referer URLs has a
# cost higher or equal to 4, it's a referer spammer.
# key, cost
#-------------------------------------------------------
%RefererSpamKeys = (
'adult'=>1,
'anal'=>2,
'dick'=>1,
'erotic'=>2,			# erotic, erotica
'gay'=>2,
'lesbian'=>2,
'free'=>1,
'porn'=>2,
'sex'=>2,

'full-list.net'=>4,
'voodoomachine.com'=>4,
'mastodonte.com'=>4,
'surfnomore.com'=>4,
'raverpussies.com'=>4,
'quiveringfuckholes.com'=>4,
'burningbush.netfirms.com'=>4,
'lesbo-tennie-girls.lesbian-hardcore-porn-teen-pics.com'=>4,
'free-people-search-engines.com'=>4,
'iaea.org'=>4,
'1stchoicecolo.com'=>4,
'globoads.com'=>4,
'morganindustriesinc.com'=>4,
'chicagodrugclub.com'=>4,
'massivecocks.com'=>4,

);


1;
