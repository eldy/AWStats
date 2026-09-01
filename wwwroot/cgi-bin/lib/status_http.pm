# AWSTATS HTTP STATUS DATABASE
#-------------------------------------------------------
# If you want to add a HTTP status code, you must add
# an entry in httpcodelib.
#-------------------------------------------------------
# Based on: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
# Last updated: 2026-04-15
#-------------------------------------------------------

#package AWSHTTPCODES;

# httpcodelib
# This list is used to found description of a HTTP status code
#-----------------------------------------------------------------
%httpcodelib = (
#------------------------------------------------------------------------------
# 1xx Informational responses
#------------------------------------------------------------------------------
'100' => _t("Continue"),
'101' => _t("Switching Protocols"),
'102' => _t("Processing (WebDAV)"),
'103' => _t("Early Hints"),

#------------------------------------------------------------------------------
# 2xx Success
#------------------------------------------------------------------------------
'2xx' => _t("[Miscellaneous successes]"),
'200' => _t("Request successful"),
'201' => _t("Created successfully"),
'202' => _t("Accepted - processing"),
'203' => _t("Non-authoritative information (from cache)"),
'204' => _t("Success, no content returned"),
'205' => _t("Reset content"),
'206' => _t("Partial content (resume download)"),
'207' => _t("Multi-status (WebDAV)"),
'208' => _t("Already reported (WebDAV)"),
'226' => _t("IM used"),

#------------------------------------------------------------------------------
# 3xx Redirection
#------------------------------------------------------------------------------
'3xx' => _t("[Miscellaneous redirections]"),
'300' => _t("Multiple choices"),
'301' => _t("Moved permanently - update your links"),
'302' => _t("Temporary redirect - URL unchanged"),
'303' => _t("See other"),
'304' => _t("Not modified - using cached version"),
'305' => _t("Use proxy"),
'306' => _t("Switch proxy"),
'307' => _t("Temporary redirect (keep method)"),
'308' => _t("Permanent redirect - update your links"),

#------------------------------------------------------------------------------
# 4xx Client errors
#------------------------------------------------------------------------------
'4xx' => _t("[Miscellaneous client/user errors]"),
'400' => _t("Bad request"),
'401' => _t("Unauthorized - please log in"),
'402' => _t("Payment required"),
'403' => _t("Forbidden - access denied"),
'404' => _t("Page not found (404) - check for broken links"),
'405' => _t("Method not allowed"),
'406' => _t("Not acceptable"),
'407' => _t("Proxy authentication required"),
'408' => _t("Request timeout"),
'409' => _t("Conflict - please try again"),
'410' => _t("Gone - permanently deleted"),
'411' => _t("Length required"),
'412' => _t("Precondition failed"),
'413' => _t("Payload too large"),
'414' => _t("URI too long"),
'415' => _t("Unsupported media type"),
'416' => _t("Range not satisfiable"),
'417' => _t("Expectation failed"),
'418' => _t("I am a teapot (April Fools)"),
'419' => _t("Page expired (Laravel)"),
'420' => _t("Method failure (Spring)"),
'421' => _t("Misdirected request"),
'422' => _t("Unprocessable entity (WebDAV)"),
'423' => _t("Locked (WebDAV)"),
'424' => _t("Failed dependency (WebDAV)"),
'425' => _t("Too early"),
'426' => _t("Upgrade required"),
'428' => _t("Precondition required"),
'429' => _t("Too many requests - slow down"),
'430' => _t("Request header fields too large (Shopify)"),
'431' => _t("Request header too large"),
'440' => _t("Login timeout (IIS)"),
'444' => _t("No response (nginx)"),
'449' => _t("Retry with (IIS)"),
'450' => _t("Blocked by Windows parental controls"),
'451' => _t("Unavailable for legal reasons"),
'460' => _t("Client closed connection before idle timeout (AWS ELB)"),
'463' => _t("X-Forwarded-For header with >30 IP addresses (AWS ELB)"),
'464' => _t("Incompatible protocol versions (AWS ELB)"),
'494' => _t("Request header too large (nginx)"),
'495' => _t("SSL certificate error (nginx)"),
'496' => _t("SSL certificate required (nginx)"),
'497' => _t("HTTP request sent to HTTPS port (nginx)"),
'498' => _t("Invalid token (ArcGIS)"),
'499' => _t("Token required (ArcGIS) / Client closed request (nginx)"),
'508' => _t("Resource limit reached (cPanel)"),
'509' => _t("Bandwidth limit exceeded (Apache/cPanel)"),

#------------------------------------------------------------------------------
# 5xx Server errors
#------------------------------------------------------------------------------
'5xx' => _t("[Miscellaneous server errors]"),
'500' => _t("Internal server error - check logs"),
'501' => _t("Not implemented"),
'502' => _t("Bad gateway - backend error"),
'503' => _t("Service unavailable - maintenance or overload"),
'504' => _t("Gateway timeout"),
'505' => _t("HTTP version not supported"),
'506' => _t("Variant also negotiates"),
'507' => _t("Insufficient storage (WebDAV)"),
'508' => _t("Loop detected (WebDAV)"),
'510' => _t("Not extended"),
'511' => _t("Network authentication required"),
'520' => _t("Unknown error (Cloudflare)"),
'521' => _t("Web server is down (Cloudflare)"),
'522' => _t("Connection timeout (Cloudflare)"),
'523' => _t("Origin is unreachable (Cloudflare)"),
'524' => _t("A timeout occurred (Cloudflare)"),
'525' => _t("SSL handshake failed (Cloudflare)"),
'526' => _t("Invalid SSL certificate (Cloudflare)"),
'527' => _t("Railgun error (Cloudflare - obsolete)"),
'529' => _t("Site is overloaded (SSLLabs)"),
'530' => _t("Origin DNS error (Cloudflare) / Site is frozen (Pantheon)"),
'540' => _t("Temporarily disabled (Shopify)"),
'561' => _t("Unauthorized (AWS ELB)"),
'598' => _t("Network read timeout error"),
'599' => _t("Network connect timeout error"),
'783' => _t("Unexpected token (Shopify)"),
'999' => _t("Request denied (LinkedIn)"),

# Special codes
'000' => _t("HTTP/2 GOAWAY (AWS ELB)"),

# Unknown fallback
'xxx' => _t("[Unknown]"),
);

1;