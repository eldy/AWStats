// awstats_misc_tracker.js
//-------------------------------------------------------------------
// You can add this file onto some of your web pages (main home page can
// be enough) by adding the following HTML code to your page body:
//
// <script language=javascript src="/js/awstats_misc_tracker.js"></script>
// <noscript><img src="/js/awstats_misc_tracker.js?nojs=y" height=0 width=0 border=0 style="display: none"></noscript>
//
// * This must be added after the <body> tag, not placed within the
//   <head> tags, or the resulting tracking <img> tag will not be handled
//   correctly by all browsers.  Internet explorer will also not report
//   screen height and width attributes until it begins to render the
//   body.
//
// This allows AWStats to be enhanced with some miscellanous features:
// - Screen size detection (TRKscreen)
// - Browser size detection (TRKwinsize)
// - Screen color depth detection (TRKcdi)
// - Java enabled detection (TRKjava)
// - Macromedia Director plugin detection (TRKshk)
// - Macromedia Shockwave plugin detection (TRKfla)
// - Realplayer G2 plugin detection (TRKrp)
// - QuickTime plugin detection (TRKmov)
// - Mediaplayer plugin detection (TRKwma)
// - Acrobat PDF plugin detection (TRKpdf)
//-------------------------------------------------------------------

// If you use pslogger.php to generate your log, you can change this line with
// var awstatsmisctrackerurl="pslogger.php?loc=/js/awstats_misc_tracker.js";
var awstatsmisctrackerurl="/js/awstats_misc_tracker.js";

function awstats_setCookie(TRKNameOfCookie, TRKvalue, TRKexpirehours) {
	var TRKExpireDate = new Date ();
  	TRKExpireDate.setTime(TRKExpireDate.getTime() + (TRKexpirehours * 3600 * 1000));
  	document.cookie = TRKNameOfCookie + "=" + escape(TRKvalue) + "; path=/" + ((TRKexpirehours == null) ? "" : "; expires=" + TRKExpireDate.toGMTString());
}

function awstats_detectIE(TRKClassID) {
	TRKresult = false;
	document.write('<SCR' + 'IPT LANGUAGE=VBScript>\n on error resume next \n TRKresult = IsObject(CreateObject("' + TRKClassID + '"))</SCR' + 'IPT>\n');
	if (TRKresult) return 'y';
	else return 'n';
}

function awstats_detectNS(TRKClassID) {
	TRKn = "n";
	if (TRKnse.indexOf(TRKClassID) != -1) if (navigator.mimeTypes[TRKClassID].enabledPlugin != null) TRKn = "y";
	return TRKn;
}

function awstats_getCookie(TRKNameOfCookie){
	if (document.cookie.length > 0){
		TRKbegin = document.cookie.indexOf(TRKNameOfCookie+"=");
	    if (TRKbegin != -1) {
			TRKbegin += TRKNameOfCookie.length+1; 
			TRKend = document.cookie.indexOf(";", TRKbegin);
			if (TRKend == -1) TRKend = document.cookie.length;
    	  	return unescape(document.cookie.substring(TRKbegin, TRKend));
		}
		return null; 
  	}
	return null; 
}

if (window.location.search == "") {

	TRKnow = new Date();
	TRKscreen=screen.width+"x"+screen.height;
	if (navigator.appName != "Netscape") {TRKcdi=screen.colorDepth}
	else {TRKcdi=screen.pixelDepth};
	TRKjava=navigator.javaEnabled();
	TRKuserid=awstats_getCookie("AWSUSER_ID");
	TRKsessionid=awstats_getCookie("AWSSESSION_ID");
	var TRKrandomnumber=Math.floor(Math.random()*10000);
	if (TRKuserid == null || (TRKuserid=="")) {TRKuserid = "awsuser_id" + TRKnow.getTime() +"r"+ TRKrandomnumber};
	if (TRKsessionid == null || (TRKsessionid=="")) {TRKsessionid = "awssession_id" + TRKnow.getTime() +"r"+ TRKrandomnumber};
	awstats_setCookie("AWSUSER_ID", TRKuserid, 10000);
	awstats_setCookie("AWSSESSION_ID", TRKsessionid, 1);
	TRKuserid=""; TRKuserid=awstats_getCookie("AWSUSER_ID");
	TRKsessionid=""; TRKsessionid=awstats_getCookie("AWSSESSION_ID");
	
	var TRKagt=navigator.userAgent.toLowerCase();
	var TRKie  = (TRKagt.indexOf("msie") != -1);
	var TRKns  = (navigator.appName.indexOf("Netscape") != -1);
	var TRKwin = ((TRKagt.indexOf("win")!=-1) || (TRKagt.indexOf("32bit")!=-1));
	var TRKmac = (TRKagt.indexOf("mac")!=-1);

    // Detect the browser internal width and height
    if (document.documentElement && document.documentElement.clientWidth)
        TRKwinsize = document.documentElement.clientWidth + 'x' + document.documentElement.clientHeight;
    else if (document.body)
        TRKwinsize = document.body.clientWidth + 'x' + document.body.clientHeight;
    else
        TRKwinsize = window.innerWidth + 'x' + window.innerHeight;
	
	if (TRKie && TRKwin) {
		var TRKshk = awstats_detectIE("SWCtl.SWCtl.1")
		var TRKfla = awstats_detectIE("ShockwaveFlash.ShockwaveFlash.1")
		var TRKrp  = awstats_detectIE("rmocx.RealPlayer G2 Control.1")
		var TRKmov = awstats_detectIE("QuickTimeCheckObject.QuickTimeCheck.1")
		var TRKwma = awstats_detectIE("MediaPlayer.MediaPlayer.1")
		var TRKpdf = 'n'; 
        if (awstats_detectIE("PDF.PdfCtrl.1") == 'y') { TRKpdf = 'y'; }
	    if (awstats_detectIE('PDF.PdfCtrl.5') == 'y') { TRKpdf = 'y'; }
		if (awstats_detectIE('PDF.PdfCtrl.6') == 'y') { TRKpdf = 'y'; }
	}
	if (TRKns || !TRKwin) {
		TRKnse = ""; for (var TRKi=0;TRKi<navigator.mimeTypes.length;TRKi++) TRKnse += navigator.mimeTypes[TRKi].type.toLowerCase();
		var TRKshk = awstats_detectNS("application/x-director")
		var TRKfla = awstats_detectNS("application/x-shockwave-flash")
		var TRKrp  = awstats_detectNS("audio/x-pn-realaudio-plugin")
		var TRKmov = awstats_detectNS("video/quicktime")
		var TRKwma = awstats_detectNS("application/x-mplayer2")
		var TRKpdf = awstats_detectNS("application/pdf");
	}
	document.write('<img src="'+awstatsmisctrackerurl+'?screen='+TRKscreen+'&win='+TRKwinsize+'&cdi='+TRKcdi+'&java='+TRKjava+'&shk='+TRKshk+'&fla='+TRKfla+'&rp='+TRKrp+'&mov='+TRKmov+'&wma='+TRKwma+'&pdf='+TRKpdf+'&uid='+TRKuserid+'&sid='+TRKsessionid+'" height=0 width=0 border=0>')

}
