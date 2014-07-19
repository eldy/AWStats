# AWSTATS MIME DATABASE
#-------------------------------------------------------
# If you want to add MIME types,
# you must add an entry in MimeHashLib and assign it to a family
#-------------------------------------------------------


#package AWSMIME;

# MimeHashFamily
# This is a hash table of mime groupings and descriptions. 
# Report icons will appear if names the same as a family, e.g.
# if you have a "text.png" icon in the icon/mime directory, the
# report will load the icon
# Format: 	'family', 'descriptive text',
#---------------------------------------------------------------
%MimeHashFamily = (
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
'jscript',	 'JavaScript file',
'vbs',       'Visual Basic script',
'conf',      'Config file',
'css',       'Cascading Style Sheet file',
'xsl',       'Extensible Stylesheet Language file',
'runtime',   'Binary runtime',
'library',   'Binary library',
'swf',       'Adobe Flash Animation',
'flv',       'Adobe Flash Video',
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
'dotnet',	 'Dot Net Dynamic Script or File',
'mdb', 		 'MS Database Object',
'crystal',	 'Crystal Reports data or file',
'ooffice',	 'Open Office Document',
'encrypt',	 'Encrypted document',
);

# MimeHashLib
# This is a hash of arrays where the key is a specific file extension
# and the array is a list of family and file type, e.g. 'd' for download
# If a file does not have a type defined, it is counted as a page. Each
# mime entry can have only one type
# Format:	'extension', ['family', 'type'],
# Valid Types:
#		i - image
#		d - download
#		p - page
#---------------------------------------------------------------
%MimeHashLib=(
# Text file
'txt',['text','d'],
'log',['text','d'],
# HTML Static page
'chm',['page',''],
'html',['page',''],
'htm',['page',''],
'mht',['page',''],
'wml',['page',''],
'wmlp',['page',''],
'xhtml',['page',''],
'xml',['page',''],
'vak',['page',''],
'sgm',['page',''],
'sgml',['page',''],
# HTML Dynamic pages or script
'asp',['script',''],
'aspx',['dotnet',''],
'ashx',['dotnet',''], 
'asmx',['dotnet',''],
'axd', ['dotnet',''],
'cfm',['script',''],
'class',['script',''],
'js',['jscript',''],
'jsp',['script',''],
'cgi',['script',''],
'ksh',['script',''],
'php',['php',''],
'php3',['php',''],
'php4',['php',''],
'pl',['pl',''],
'py',['script',''],
'rss',['rss',''],
'sh',['script',''],
'shtml',['script',''],
'tcl',['script',''],
'xsp',['script',''],
'vbs',['vbs',''],
# Image
'gif',['image','i'],
'png',['image','i'],
'bmp',['image','i'],
'jpg',['image','i'],
'jpeg',['image','i'],
'cdr',['image','d'],
'ico',['image','i'],
'svg',['image','i'],
# Document
'ai',['document','d'],
'doc',['document','d'],
'docx',['document','d'],
'wmz',['document','d'],
'rtf',['document','d'],
'mso',['document','d'],
'pdf',['pdf','d'],
'frl',['pdf','d'],
'xls',['document','d'],
'xlsx',['document','d'],
'ppt',['document','d'],
'pptx',['document','d'],
'pps',['document','d'],
'psd',['document','d'],
'sxw',['ooffice','d'],
'sxc',['ooffice','d'],
'sxi',['ooffice','d'],
'sxd',['ooffice','d'],
'sxm',['ooffice','d'],
'sxg',['ooffice','d'],
'csv',['csv','d'],
'xsl',['xsl','d'],
'lit',['lit','d'],
'mdb',['mdb',''],
'rpt',['crystal',''],
# Package
'rpm',[($LogType eq 'S'?'audio':'package'),'d'],
'deb',['package','d'],
'msi',['package','d'],
# Archive
'7z',['archive','d'],
'ace',['archive','d'],
'bz2',['archive','d'],
'cab',['archive','d'],
'emz',['archive','d'],
'gz',['archive','d'],
'jar',['archive','d'],
'lzma',['archive','d'],
'rar',['archive','d'],
'tar',['archive','d'],
'tgz',['archive','d'],
'tbz2',['archive','d'],
'z',['archive','d'],
'zip',['archive','d'],
# Audio
'aac',['audio','d'],
'flac',['audio','d'],
'mp3',['audio','d'],
'oga',['audio','d'],
'ogg',['audio','d'],
'wav',['audio','d'],
'wma',['audio','d'],
'm4a',['audio','d'],
'm3u',['audio','d'],
'asf',['audio','d'],
# Video
'avi',['video','d'],
'divx',['video','d'],
'mp4',['video','d'],
'm4v',['video','d'],
'mpeg',['video','d'],
'mpg',['video','d'],
'ogv',['video','d'],
'ogx',['video','d'],
'rm',['video','d'],
'swf',['flash',''],
'flv',['flash','d'],
'f4v',['flash','d'],
'wmv',['video','d'],
'wmf',['video','d'],
'mov',['video','d'],
'qt',['video','d'],
# Config
'cf',['conf',''],
'conf',['conf',''],
'css',['css',''],
'ini',['conf',''],
'dtd',['dtd',''],
# Program
'exe',['runtime',''],
'jnlp',['jnlp',''],
'dll',['library',''],
'bin',['library',''],
# Font
'ttf',['ttf',''],
'fon',['fon',''],
# Encrypted files
'pgp',['encrypt',''],
'gpg',['encrypt',''],
);


1;
