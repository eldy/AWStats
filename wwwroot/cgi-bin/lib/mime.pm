# AWSTATS MIME DATABASE
#-------------------------------------------------------
# If you want to add MIME types,
# you must add an entry in MimeFamily and may be MimeHashLib
#-------------------------------------------------------
# $Revision$ - $Author$ - $Date$


#package AWSMIME;


# MimeHashLib
# List of mime's label ("mime id in lower case", "mime text")
#---------------------------------------------------------------
%MimeHashLib = (
'text','Text file',
'page','HTML static page',
'script','HTML dynamic page or Script file',
'image','Image',
'document','Document',
'archive','Archive',
'audio','Audio',
'video','Video',
'javascript','Javascript file',
'conf','Config file',
'css','Cascading Style Sheet',
'runtime','HTML dynamic page or Binary runtime',
'library','Binary library',
);

# MimeHashIcon
# Each Mime ID is associated to a string that is the name of icon
# file for this Mime type.
#---------------------------------------------------------------------------
%MimeHashIcon = (
# Text file
'txt','text',
# HTML Static page
'html','html',
'htm','html',
# HTML Dynamic pages or script
'cgi','script',
'ksh','script',
'php','script',
'php3','script',
'php4','script',
'pl','script',
'py','script',
'sh','script',
'shtml','html',
'tcl','script',
# Image
'gif','image',
'png','image',
'bmp','image',
'jpg','image',
'jpeg','image',
# Document
'doc','doc',
'pdf','pdf',
'xls','other',
'ppt','other',
'pps','other',
'sxw','other',
'sxc','other',
'sxi','other',
'sxd','other',
# Archive
'zip','archive',
'tgz','archive',
'tar','archive',
'gz','archive',
'rar','archive',
'7z','archive',
'bz2','archive',
# Audio
'mp3','audio',
'ogg','audio',
'wma','audio',
'wav','audio',
# Video
'avi','video',
'divx','video',
'mpeg','video',
'mpg','video',
# JS
'js','other',
# Config
'cf','other',
'conf','other',
'css','other',
'ini','other',
# Program
'exe','script',
'dll','script',
);


%MimeHashFamily=(
# Text file
'txt','page',
# HTML Static page
'html','page',
'htm','page',
# HTML Dynamic pages or script
'cgi','script',
'ksh','script',
'php','script',
'php3','script',
'php4','script',
'pl','script',
'py','script',
'sh','script',
'shtml','script',
'tcl','script',
# Image
'gif','image',
'png','image',
'bmp','image',
'jpg','image',
'jpeg','image',
# Document
'doc','document',
'pdf','document',
'xls','document',
'ppt','document',
'pps','document',
'sxw','document',
'sxc','document',
'sxi','document',
'sxd','document',
# Archive
'7z','archive',
'bz2','archive',
'zip','archive',
'tgz','archive',
'tar','archive',
'gz','archive',
'rar','archive',
# Audio
'mp3','audio',
'ogg','audio',
'wav','audio',
'wma','audio',
# Video
'avi','video',
'divx','video',
'mpeg','video',
'mpg','video',
# JS
'js','javascript',
# Config
'cf','conf',
'conf','conf',
'css','css',
'ini','conf',
# Program
'exe','runtime',
'dll','library',
);


1;
