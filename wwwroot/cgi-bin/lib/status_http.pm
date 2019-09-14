# AWSTATS HTTP STATUS DATABASE
#-------------------------------------------------------
# If you want to add a HTTP status code, you must add
# an entry in httpcodelib.
#-------------------------------------------------------


#package AWSHTTPCODES;

# from https://en.wikipedia.org/wiki/List_of_HTTP_status_codes

# httpcodelib
# This list is used to found description of a HTTP status code
#-----------------------------------------------------------------
%httpcodelib = (
'100'=>'Continue',
'101'=>'Switching Protocols',
'102'=>'Processing (WebDAV)',
'103'=>'Early Hints',
#[Miscellaneous successes]
'2xx'=>'[Miscellaneous successes]',
'200'=>'OK',								# HTTP request OK
'201'=>'Created',
'202'=>'Accepted',
'203'=>'Non-authoritative Information',
'204'=>'No Content',
'205'=>'Reset Content',
'206'=>'Partial Content',
'207'=>'Multi-Status (WebDAV)',
'208'=>'Already Reported (WebDAV)',
'226'=>'IM Used',
#[Miscellaneous redirections]
'3xx'=>'[Miscellaneous redirections]',
'300'=>'Multiple Choices',
'301'=>'Moved Permanently (redirect)',
'302'=>'Found (Previously "Moved temporarily")',
'303'=>'See Other',
'304'=>'Not Modified (since last retrieval)',	# HTTP request OK
'305'=>'Use Proxy',
'306'=>'Switch Proxy',
'307'=>'Temporary Redirect',
'308'=>'Permanent Redirect',
#[Miscellaneous client/user errors]
'4xx'=>'[Miscellaneous client/user errors]',
'400'=>'Bad Request',
'401'=>'Unauthorized',
'402'=>'Payment Required',
'403'=>'Forbidden',
'404'=>'Not Found (hits on favicon excluded)',
'405'=>'Method Not Allowed',
'406'=>'Not Acceptable',
'407'=>'Proxy Authentication Required',
'408'=>'Request Timeout',
'409'=>'Conflict',
'410'=>'Gone',
'411'=>'Length Required',
'412'=>'Precondition Failed',
'413'=>'Payload Too Large',
'414'=>'URI Too Long',
'415'=>'Unsupported Media Type',
'416'=>'Range Not Satisfiable',
'417'=>'Expectation Failed',
'418'=>'I am a teapot',
'421'=>'Misdirected Request',
'422'=>'Unprocessable Entity (WebDAV)',
'423'=>'Locked (WebDAV)',
'424'=>'Failed Dependency (WebDAV)',
'425'=>'Too Early',
'426'=>'Upgrade Required',
'428'=>'Precondition Required',
'429'=>'Too Many Requests',
'431'=>'Request Header Fields Too Large',
'451'=>'Unavailable For Legal Reasons',
#[Miscellaneous server errors]
'5xx'=>'[Miscellaneous server errors]',
'500'=>'Internal Server Error',
'501'=>'Not Implemented',
'502'=>'Bad Gateway',
'503'=>'Service Unavailable',
'504'=>'Gateway Timeout',
'505'=>'HTTP Version Not Supported',
'506'=>'Variant Also Negotiates',
'507'=>'Insufficient Storage (WebDAV)',
'508'=>'Loop Detected (WebDAV)',
'510'=>'Not Extended',
'511'=>'Network Authentication Required',
#[Unofficial codes]
'103'=>'Checkpoint',
'218'=>'This is fine (Apache Web Server)',
'419'=>'Page Expired (Laravel Framework)',
'420'=>'Method Failure (Spring Framework) / Enhance Your Calm (Twitter)',
'430'=>'Request Header Fields Too Large (Shopify)',
'440'=>'Login Time-out (IIS)',
'444'=>'No Response (nginx)',
'449'=>'Retry With (IIS)',
'450'=>'Blocked by Windows Parental Controls (Microsoft)',
'451'=>'Redirect (IIS)',
'460'=>'Client closed the connection with the load balancer before the idle timeout period elapsed (AWS ELB)',
'463'=>'The load balancer received an X-Forwarded-For request header with more than 30 IP addresses (AWS ELB)',
'494'=>'Request header too large (nginx)',
'495'=>'SSL Certificate Error (nginx)',
'496'=>'SSL Certificate Required (nginx)',
'497'=>'HTTP Request Sent to HTTPS Port (nginx)',
'498'=>'Invalid Token (Esri)',
'499'=>'Client Closed Request (nginx) / Token Required (Esri)',
'509'=>'Bandwidth Limit Exceeded (Apache Web Server/cPanel)',
'520'=>'Unknown Error (Cloudflare)',
'521'=>'Web Server Is Down (Cloudflare)',
'522'=>'Connection Timed Out (Cloudflare)',
'523'=>'Origin Is Unreachable (Cloudflare)',
'524'=>'A Timeout Occurred (Cloudflare)',
'525'=>'SSL Handshake Failed (Cloudflare)',
'526'=>'Invalid SSL Certificate (Cloudflare)',
'527'=>'Railgun Error (Cloudflare)',
'530'=>'Origin DNS Error (Cloudflare) / Site is frozen (Pantheon web platform)',
'598'=>'(Informal convention) Network read timeout error',

#[Unknown]
'xxx'=>'[Unknown]'
);


1;
