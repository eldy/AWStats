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
'text',      'Text file',
'page',      'HTML or XML static page',
'script',    'Dynamic Html page or Script file',
'pl',        'Dynamic Perl Script file',
'php',       'Dynamic PHP Script file',
'image',     'Image',
'document',  'Document',
'package',   'Package',
'archive',   'Archive',
'audio',     'Audio file',
'video',     'Video file',
'javascript','JavaScript file',
'vbs',       'Visual Basic script',
'conf',      'Config file',
'css',       'Cascading Style Sheet file',
'xsl',       'Extensible Stylesheet Language file',
'runtime',   'Binary runtime',
'library',   'Binary library',
'swf',       'Macromedia Flash Animation',
'dtd',       'Document Type Definition',
'csv',       'Comma Separated Value file',
'jnlp',      'Java Web Start launch file',
'lit',       'Microsoft Reader e-book',
'svg',       'Scalable Vector Graphics',
'ai',        'Adobe Illustrator file',
'phshop',    'Adobe Photoshop image file',
'ttf',       'TrueType scalable font file',
'fon',       'Font file',
'pdf',       'Adobe Acrobat file',
);

# MimeHashIcon
# Each Mime ID is associated to a string that is the name of icon
# file for this Mime type.
#---------------------------------------------------------------------------
%MimeHashIcon = (
# Text file
'txt','text',
'log','text',
# HTML Static page
'html','html',
'htm','html',
'hdml','html',
'wml','html',
'wmlp','html',
'xhtml','html',
'xml','html',
'vak','glasses',
'sgm','html',
'sgml','html',
# HTML Dynamic pages or script
'asp','script',
'aspx','script', 
'asmx','script', 
'cfm','script',
'jsp','script',
'cgi','script',
'ksh','script',
'php','php',
'php3','php',
'php4','php',
'pl','pl',
'py','script',
'sh','script',
'shtml','html',
'tcl','script',
'xsp','script',
# Image
'gif','image',
'png','image',
'bmp','image',
'jpg','image',
'jpeg','image',
'cdr','image',
'ico','image',
'svg','svg',
'psd','phshop',
# Document
'doc','doc',
'wmz','doc',
'rtf','doc',
'pdf','pdf',
'xls','xls',
'ppt','ppt',
'pps','ppt',
'sxw','other',
'sxc','other',
'sxi','other',
'sxd','other',
'csv','other',
'xsl','html',
'lit','lit',
'ai','ai',
# Package
'rpm',($LogType eq 'S'?'audio':'archive'),
'deb','archive',
'msi','archive',
# Archive
'7z','archive',
'ace','archive',
'bz2','archive',
'gz','archive',
'jar','archive',
'rar','archive',
'tar','archive',
'tgz','archive',
'tbz2','archive',
'z','archive',
'zip','archive',
# Audio
'mp3','audio',
'ogg','audio',
'wma','audio',
'wav','audio',
# Video
'avi','video',
'divx','video',
'mp4','video',
'mpeg','video',
'mpg','video',
'rm','real',
'swf','flash',
'wmv','video',
'mov','quicktime',
'qt','quicktime',
# Web scripts
'js','jscript',
'vbs','jscript',
# Config
'cf','other',
'conf','other',
'css','other',
'ini','other',
'dtd','other',
# Program
'exe','script',
'dll','script',
'jnlp','jnlp',
# Fonts
'ttf','ttf',
'fon','fon',
);


%MimeHashFamily=(
# Text file
'txt','text',
'log','text',
# HTML Static page
'html','page',
'htm','page',
'wml','page',
'wmlp','page',
'xhtml','page',
'xml','page',
'vak','page',
'sgm','page',
'sgml','page',
# HTML Dynamic pages or script
'asp','script',
'aspx','script', 
'asmx','script', 
'cfm','script',
'jsp','script',
'cgi','script',
'ksh','script',
'php','php',
'php3','php',
'php4','php',
'pl','pl',
'py','script',
'sh','script',
'shtml','script',
'tcl','script',
'xsp','script',
# Image
'gif','image',
'png','image',
'bmp','image',
'jpg','image',
'jpeg','image',
'cdr','image',
'ico','image',
'svg','svg',
'psd','phshop',
'ai','ai',
# Document
'doc','document',
'wmz','document',
'rtf','document',
'pdf','pdf',
'xls','document',
'ppt','document',
'pps','document',
'sxw','document',
'sxc','document',
'sxi','document',
'sxd','document',
'csv','csv',
'xsl','xsl',
'lit','lit',
# Package
'rpm',($LogType eq 'S'?'audio':'package'),
'deb','package',
'msi','package',
# Archive
'7z','archive',
'ace','archive',
'bz2','archive',
'gz','archive',
'jar','archive',
'rar','archive',
'tar','archive',
'tgz','archive',
'tbz2','archive',
'z','archive',
'zip','archive',
# Audio
'mp3','audio',
'ogg','audio',
'wav','audio',
'wma','audio',
# Video
'avi','video',
'divx','video',
'mp4','video',
'mpeg','video',
'mpg','video',
'rm','video',
'swf','swf',
'wmv','video',
'mov','video',
'qt','video',
# Web scripts
'js','javascript',
'vbs','vbs',
# Config
'cf','conf',
'conf','conf',
'css','css',
'ini','conf',
'dtd','dtd',
# Program
'exe','runtime',
'jnlp','jnlp',
'dll','library',
# Font
'ttf','ttf',
'fon','fon',
);


1;
