# AWSTATS SMTP STATUS DATABASE
#-------------------------------------------------------
# If you want to add a SMTP status code, you must add
# an entry in smtpcodelib.
#-------------------------------------------------------


#package AWSSMTPCODES;


# smtpcodelib
# This list is used to found description of a SMTP status code
#-----------------------------------------------------------------
%smtpcodelib = (
#[Successfull code]
'200'=>'Nonstandard success response',
'211'=>'System status, or system help reply',
'214'=>'Help message',
'220'=>'<domain> Service ready',
'221'=>'<domain> Service closing transmission channel',
'250'=>'Requested mail action taken and completed',	# Your ISP mail server have successfully executes a command and the DNS is reporting a positive delivery.
'251'=>'User not local: will forward to <forward-path>',	# Your message to a specified email address is not local to the mail server, but it will accept and forward the message to a different recipient email address.
'252'=>'Recipient cannot be verified',	# but mail server accepts the message and attempts delivery.
'354'=>'Start mail input and end with <CRLF>.<CRLF>',	# Indicates mail server is ready to accept the message or instruct your mail client to send the message body after the mail server have received the message headers.
#[Temporary error code] Ask sender to try later to complete successfully
'421'=>'<domain> Service not available, closing transmission channel',	# This may be a reply to any command if the service knows it must shut down.
'450'=>'Requested mail action not taken: mailbox busy, DNS check failed or access denied for other reason',	# Your ISP mail server indicates that an email address does not exist or the mailbox is busy. It could be the network connection went down while sending, or it could also happen if the remote mail server does not want to accept mail from you for some reason i.e. (IP address, From address, Recipient, etc.)
'451'=>'Requested mail action aborted: error in processing',	# Your ISP mail server indicates that the mailing has been interrupted, usually due to overloading from too many messages or transient failure is one in which the message sent is valid, but some temporary event prevents the successful sending of the message. Sending in the future may be successful.
'452'=>'Requested mail action not taken: insufficient system storage',	# Your ISP mail server indicates, probable overloading from too many messages and sending in the future may be successful.
'453'=>'Too many messages',	# Some mail servers have the option to reduce the number of concurrent connection and also the number of messages sent per connection. If you have a lot of messages queued up it could go over the max number of messages per connection. To see if this is the case you can try submitting only a few messages to that domain at a time and then keep increasing the number until you find the maximum number accepted by the server.

# Postfix code for unknown_client_reject_code (postfix default=450) with reject_unknown_clients rule
'470'=>'Access denied: Unknown SMTP client hostname (without DNS A or MX record)',
# Postfix code for unknown_address_reject_code (postfix default=450) with reject_unknown_sender_domain rule
'471'=>'Access denied: Unknown domain for sender or recipient email address (without DNS A or MX record)',

#[Permanent error code]
'500'=>'Syntax error, command unrecognized or command line too long',
'501'=>'Syntax error in parameters or arguments',
'502'=>'Command not implemented',
'503'=>'Server encountered bad sequence of commands',
'504'=>'Command parameter not implemented',
'521'=>'<domain> does not accept mail or closing transmission channel', # You must be pop-authenticated before you can use this SMTP server and you must use your mail address for the Sender/From field.
'530'=>'Access denied', # a Sendmailism ?
'550'=>'Requested mail action not taken: relaying not allowed, unknown recipient user, ...',	# Sending an email to recipients outside of your domain are not allowed or your mail server does not know that you have access to use it for relaying messages and authentication is required. Or to prevent the sending of SPAM some mail servers will not allow (relay) send mail to any e-mail using another company�s network and computer resources.
'551'=>'User not local: please try <forward-path> or Invalid Address: Relay request denied',
'552'=>'Requested mail action aborted: exceeded storage allocation',	# ISP mail server indicates, probable overloading from too many messages.
'553'=>'Requested mail action not taken: mailbox name not allowed',	# Some mail servers have the option to reduce the number of concurrent connection and also the number of messages sent per connection. If you have a lot of messages queued up (being sent) for a domain, it could go over the maximum number of messages per connection and/or some change to the message and/or destination must be made for successful delivery.
'554'=>'Requested mail action rejected: access denied',
'557'=>'Too many duplicate messages', # Resource temporarily unavailable Indicates (probable) that there is some kind of anti-spam system on the mail server.

# Postfix code for access_map_reject_code (postfix default=554) with access map rule
'570'=>'Access denied: access_map violation (on SMTP client or HELO hostname, sender or recipient email address)',
# Postfix code for maps_rbl_reject_code (postfix default=554) with maps_rbl_domains rule
'571'=>'Access denied: SMTP client listed in RBL',
# Postfix code for relay_domains_reject_code (postfix default=554) with relay_domains_reject rule
'572'=>'Access denied: Relay not authorized or not local host not a gateway',
# Postfix code for unknown_client_reject_code (postfix default=450) with reject_unknown_client rule
'573'=>'Access denied: Unknown SMTP client hostname (without DNS A or MX record)',
# Postfix code for invalid_hostname_reject_code (postfix default=501) with reject_invalid_hostname rule
'574'=>'Access denied: Bad syntax for client HELO hostname (Not RFC compliant)',
# Postfix code for reject_code (postfix default=554) with smtpd_client_restrictions
'575'=>'Access denied: SMTP client hostname rejected',
# Postfix code for unknown_address_reject_code (postfix default=450) with reject_unknown_sender_domain or reject_unknown_recipient_domain rule
'576'=>'Access denied: Unknown domain for sender or recipient email address (without DNS A or MX record)',
# Postfix code for unknown_hostname_reject_code (postfix default=501) with reject_unknown_hostname rule
'577'=>'Access denied: Unknown client HELO hostname (without DNS A or MX record)',
# Postfix code for non_fqdn_reject_code (Postfix default=504) with reject_non_fqdn_hostname, reject_non_fqdn_sender or reject_non_fqdn_recipient rule 
'578'=>'Access denied: Invalid domain for client HELO hostname, sender or recipient email address (not FQDN)',
);


1;