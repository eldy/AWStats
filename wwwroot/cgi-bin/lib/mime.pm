# AWSTATS MIME DATABASE
#-------------------------------------------------------
# If you want to add MIME types,
# you must add an entry in MimeHashLib and assign it to a family
#-------------------------------------------------------
#package AWSMIME;
# MimeHashFamily
# This is a hash table of mime groupings and descriptions.
# Report icons will appear if file name is the same as a family,
# e.g. if you have a "text.png" icon in the icon/mime directory,
# the report will load the icon
# Format: 'family', 'descriptive text',
#---------------------------------------------------------------
%MimeHashFamily = (
# 基础类型
'text',      'mime_text',
'log',       'mime_log',
'page',      'mime_page',
'script',    'mime_script',
'document',  'mime_document',
'image',     'mime_image',
'audio',     'mime_audio',
'video',     'mime_video',
'package',   'mime_package',
'archive',   'mime_archive',

# 编程语言/脚本
'pl',        'mime_pl',
'php',       'mime_php',
'js',        'mime_js',
'py',        'mime_py',
'sh',        'mime_sh',
'rb',        'mime_rb',
'json',      'mime_json',
'vbs',       'mime_vbs',
'conf',      'mime_conf',
'css',       'mime_css',
'xsl',       'mime_xsl',
'runtime',   'mime_runtime',
'library',   'mime_library',
'f4v',       'mime_f4v',
'dtd',       'mime_dtd',
'csv',       'mime_csv',
'jnlp',      'mime_jnlp',
'lit',       'mime_lit',
'svg',       'mime_svg',
'ai',        'mime_ai',
'photoshop', 'mime_phshop',
'ttf',       'mime_ttf',
'fon',       'mime_fon',
'pdf',       'mime_pdf',
'dotnet',    'mime_dotnet',
'md',        'mime_md',
'mdb',       'mime_mdb',
'crystal',   'mime_crystal',
'libreoffice', 'mime_libreoffice',
'encrypt',   'mime_encrypt',
'gpx',       'mime_gpx',
'diskimage', 'mime_diskimage',
'vmware',    'mime_vm',
'torrent',   'mime_torrent',
'gis',       'mime_gis',
'ebook',     'mime_ebook',
'chm',       'mime_chm',
'mht',       'mime_mht',
'wml',       'mime_wml',
'xhtml',     'mime_xhtml',
'khtml',     'mime_khtml',
'xml',       'mime_xml',
'sgm',       'mime_sgml',
'sgml',      'mime_sgml',

# 现代文件格式
'markdown',  'mime_markdown',
'yaml',      'mime_yaml',
'toml',      'mime_toml',
'vue',       'mime_vue',
'jsx',       'mime_jsx',
'tsx',       'mime_tsx',
'wasm',      'mime_wasm',

# 3D 模型文件
'gltf',      'mime_gltf',
'glb',       'mime_glb',
'gls',       'mime_gls',

# 漫画书
'cbz',       'mime_cbz',
'cbr',       'mime_cbr',
'fb2',       'mime_fb2',
'kepub',     'mime_kepub',
'm4b',       'mime_m4b',
'kfx',       'mime_kfx',

# 图片格式
'gif',       'mime_gif',
'png',       'mime_png',
'apng',      'mime_apng',
'bmp',       'mime_bmp',
'jpg',       'mime_jpg',
'jpeg',      'mime_jpeg',
'cdr',       'mime_cdr',
'cur',       'mime_cur',
'ico',       'mime_ico',
'svgz',      'mime_svg',
'webp',      'mime_webp',
'avif',      'mime_avif',
'heic',      'mime_heic',
'heif',      'mime_heif',
'tif',       'mime_tiff',
'tiff',      'mime_tiff',

# --- Archive 压缩包 ---
'7z',       'mime_7z',
'ace',      'mime_ace',
'bz2',      'mime_bz2',
'cab',      'mime_cab',
'dmg',      'mime_dmg',
'emz',      'mime_emz',
'gz',       'mime_gz',
'jar',      'mime_jar',
'lzma',     'mime_lzma',
'rar',      'mime_rar',
'tar',      'mime_tar',
'tgz',      'mime_tgz',
'tbz2',     'mime_tbz2',
'xz',       'mime_xz',
'z',        'mime_z',
'zip',      'mime_zip',
'lzo',      'mime_lzo',
'lz4',      'mime_lz4',
'zst',      'mime_zst',

# --- Package 软件包 ---
'rpm',      'mime_rpm',
'deb',      'mime_deb',
'msi',      'mime_msi',
'pkg',      'mime_pkg',
'apk',      'mime_apk',
'ipa',      'mime_ipa',
'hap',      'mime_hap',
'har',      'mime_har',
'exe',      'mime_exe',
'dll',      'mime_dll',
'com',      'mime_com',
'aab',      'mime_aab',
'xapk',     'mime_xapk',
'appx',     'mime_appx',
'msix',     'mime_msix',
'appimage', 'mime_appimage',
'flatpak',  'mime_flatpak',
'snap',     'mime_snap',
'pacman',   'mime_pacman',

# --- Audio 音频 ---
'aac',      'mime_aac',
'alac',     'mime_alac',
'ape',      'mime_ape',
'asf',      'mime_asf',
'dsf',      'mime_dsf',
'flac',     'mime_flac',
'm3u',      'mime_m3u',
'm4a',      'mime_m4a',
'mid',      'mime_mid',
'mp3',      'mime_mp3',
'oga',      'mime_oga',
'ogg',      'mime_ogg',
'opus',     'mime_opus',
'wav',      'mime_wav',
'wma',      'mime_wma',

# --- Video 视频 ---
'3gp',      'mime_3gp',
'avi',      'mime_avi',
'divx',     'mime_divx',
'f4v',      'mime_f4v',
'flv',      'mime_flv',
'm4v',      'mime_m4v',
'mkv',      'mime_mkv',
'mov',      'mime_mov',
'mp4',      'mime_mp4',
'mpeg',     'mime_mpeg',
'mpg',      'mime_mpg',
'ogv',      'mime_ogv',
'ogx',      'mime_ogx',
'qt',       'mime_qt',
'rm',       'mime_rm',
'swf',      'mime_swf',
'webm',     'mime_webm',
'wmf',      'mime_wmf',
'wmv',      'mime_wmv',
);

# MimeHashLib
# This is a hash of arrays where the key is a specific file extension
# and the array is a list of family and file type, e.g. 'd' for download
# If a file does not have a type defined, it is counted as a page. Each
# mime entry can have only one type
# Format: 'extension', ['family', 'type'],
# Valid Types:
#   i - image
#   d - download
#   p - page
#---------------------------------------------------------------
%MimeHashLib = (
# Text file
'txt',['text','d'],
'log',['log','d'],
'rb',['rb','d'],
'sh',['sh','d'],
'py',['py','d'],

# HTML Static page
'chm',['chm',''],
'html',['page',''],
'htm',['page',''],
'mht',['mht',''],
'wml',['wml',''],
'wmlp',['wml',''],
'xhtml',['page',''],
'khtml',['khtml',''],
'xml',['xml',''],
'sgm',['sgm',''],
'sgml',['sgm',''],

# HTML Dynamic pages or script
'asp',['script',''],
'aspx',['dotnet',''],
'ashx',['dotnet',''],
'asmx',['dotnet',''],
'axd',['dotnet',''],
'cfm',['script',''],
'class',['script',''],
'js',['js',''],
'mjs',['js',''],
'cjs',['js',''],
'jscript',['script',''],
'jsp',['script',''],
'cgi',['script',''],
'ksh',['script',''],
'php',['php',''],
'phps',['php',''],
'php3',['php',''],
'php4',['php',''],
'pl',['pl',''],
'rss',['rss',''],
'atom',['rss',''],
'shtml',['script',''],
'tcl',['script',''],
'xsp',['script',''],
'vbs',['script',''],

# 现代前端框架
'vue',['vue',''],
'jsx',['jsx',''],
'tsx',['tsx',''],

# WebAssembly
'wasm',['wasm',''],

# Markdown 文档
'md',['md','d'],
'markdown',['md','d'],

# Image
'gif',['gif','i'],
'png',['png','i'],
'apng',['apng','i'],
'bmp',['bmp','i'],
'jpg',['jpg','i'],
'jpeg',['jpeg','i'],
'cdr',['cdr','d'],
'cur',['cur','i'],
'ico',['ico','i'],
'svg',['svg','i'],
'svgz',['svg','i'],
'webp',['webp','i'],
'avif',['avif','i'],
'heic',['heic','i'],
'heif',['heif','i'],
'tif',['tif','i'],
'tiff',['tiff','i'],

# Document
'ai',['ai','d'],
'doc',['doc','d'],
'docx',['doc','d'],
'wmz',['document','d'],
'rtf',['document','d'],
'mso',['document','d'],

# 3D 模型文件
'gltf',['gltf','d'],
'glb',['glb','d'],
'gls',['gls','d'],

# 漫画书
'cbz',['cbz','d'],
'cbr',['cbr','d'],

# FictionBook
'fb2',['fb2','d'],

# Kobo 增强 EPUB
'kepub',['kepub','d'],

# 有声书
'm4b',['m4b','d'],

# Kindle 新格式
'kfx',['kfx','d'],

'pdf',['pdf','d'],
'frl',['pdf','d'],
'xls',['xls','d'],
'xlsx',['xls','d'],
'ppt',['ppt','d'],
'pptx',['ppt','d'],
'pps',['ppt','d'],
'psd',['psd','d'],
'psb',['psb','d'],
'photoshop',['photoshop','d'],
'odb',['LibreOffice','d'],
'odf',['LibreOffice','d'],
'odg',['LibreOffice','d'],
'odm',['LibreOffice','d'],
'odp',['LibreOffice','d'],
'ods',['LibreOffice','d'],
'odt',['LibreOffice','d'],
'oth',['LibreOffice','d'],
'otg',['LibreOffice','d'],
'otp',['LibreOffice','d'],
'ots',['LibreOffice','d'],
'ott',['LibreOffice','d'],
'oxt',['LibreOffice','d'],
'csv',['csv','d'],
'xsl',['xsl','d'],
'lit',['document','d'],
'mdb',['mdb','d'],
'rpt',['crystal','d'],
'epub',['epub','d'],
'mobi',['ebook','d'],
'azw',['ebook','d'],
'azw3',['ebook','d'],

# GIS files
'gpx',['gpx','d'],
'kml',['gis','d'],
'kmz',['gis','d'],

# Archive
'7z',['7z','d'],
'ace',['archive','d'],
'bz2',['archive','d'],
'cab',['archive','d'],
'dmg',['dmg','d'],
'emz',['archive','d'],
'gz',['archive','d'],
'jar',['archive','d'],
'lzma',['archive','d'],
'rar',['rar','d'],
'tar',['tar','d'],
'tgz',['archive','d'],
'tbz2',['archive','d'],
'xz',['archive','d'],
'z',['archive','d'],
'zip',['zip','d'],
'lzo',['zip','d'],
'lz4',['zip','d'],
'zst',['zip','d'],

# Package
'rpm',['package','d'],
'deb',['package','d'],
'msi',['package','d'],
'pkg',['package','d'],
'apk',['apk','d'],
'ipa',['ipa','d'],
'hap',['hap','d'],
'har',['har','d'],
'exe', ['executable','d'],
'dll', ['library','d'],
'com', ['executable','d'],
'aab', ['package','d'],
'xapk', ['package','d'],
'appx', ['package','d'],
'msix', ['package','d'],
'appimage', ['package','d'],
'flatpak', ['package','d'],
'snap', ['package','d'],
'pacman', ['package','d'],

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
'opus',['opus','d'],
'alac', ['audio','d'],
'dsf', ['audio','d'],
'ape', ['audio','d'],
'mid', ['audio','d'],

# Video
'avi',['video','d'],
'divx',['video','d'],
'mp4',['video','d'],
'm4v',['video','d'],
'mpeg',['video','d'],
'mkv',['video','d'],
'mpg',['video','d'],
'ogv',['video','d'],
'ogx',['video','d'],
'rm',['video','d'],
'swf',['swf','d'],
'flv',['swf','d'],
'f4v',['swf','d'],
'wmv',['wmv','d'],
'wmf',['video','d'],
'mov',['video','d'],
'qt',['qt','d'],
'webm',['video','d'],
'3gp', ['video','d'],

# Config
'cf',['conf',''],
'conf',['conf',''],
'css',['css',''],
'ini',['conf',''],
'dtd',['dtd',''],
'json',['json',''],

# YAML/TOML 配置文件
'yaml',['yaml',''],
'yml',['yaml',''],
'toml',['toml',''],

# Program
'jnlp',['jnlp',''],
'bin',['library',''],
'runtime',['runtime','d'],

# Font
'ttf',['ttf',''],
'fon',['fon',''],
'eot',['fon',''],
'woff',['fon',''],
'woff2',['fon',''],

# Encrypted files
'pgp',['encrypt',''],
'gpg',['encrypt',''],

# Disc and media file extensions
'iso',['diskimage','d'],
'toast',['diskimage','d'],
'vcd',['diskimage','d'],

# Virtual Machine images
'qcow2',['vmware','d'],
'raw',['vmware','d'],
'ovf',['vmware','d'],
'ova',['vmware','d'],
'vmdk',['vmware','d'],
'vdi',['vmware','d'],
'vhdx',['vmware','d'],
'vpc',['vmware','d'],
);

1;