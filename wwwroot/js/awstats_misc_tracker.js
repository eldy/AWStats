// awstats_more_tracker
//-------------------------------------------------------------------
// You can add this file onto some of your web pages (main home page
// can be enough) by adding the code at the bottom of page.
// <script language=javascript src="/js/awstats_more_tracker.js"></script>
// This allow AWStats to be enhanced with some miscellanous features:
// - Screen size (TRKscreen)
// - Screen color depth (TRKcdi)
// - Java enabled (TRKjava)
// - Macromedia Director plugin (TRKshk)
// - Macromedia Shockwave plugin (TRKfla)
// - Realplayer G2 plugin (TRKrp)
// - QuickTime plugin (TRKmov)
// - Mediaplayer plugin (TRKwma)
// - Acrobat PDF plugin (TRKpdf)
//-------------------------------------------------------------------


var awstatsmisctrackerurl="/js/awstats_misc_tracker.js";

function awstats_setCookie(TRKNameOfCookie, TRKvalue, TRKexpirehours) {
	var TRKExpireDate = new Date ();
  	TRKExpireDate.setTime(TRKExpireDate.getTime() + (TRKexpirehours * 3600 * 1000));
  	document.cookie = TRKNameOfCookie + "=" + escape(TRKvalue) + "; path=/" + ((TRKexpirehours == null) ? "" : "; expires=" + TRKExpireDate.toGMTString());
}

function awstats_detectIE(TRKClassID) {
	TRKresult = false;
	document.write('<SCR' + 'IPT LANGUAGE=VBScript>\n on error resume next \n TRKresult = IsObject(CreateObject("' + TRKClassID + '"))</SCR' + 'IPT>\n');
	if (TRKresult) return 'Y';
	else return 'N';
}

function awstats_detectNS(TRKClassID) {
	TRKn = "N";
	if (TRKnse.indexOf(TRKClassID) != -1) if (navigator.mimeTypes[TRKClassID].enabledPlugin != null) TRKn = "Y";
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
	//var icon="";
	//var TRKr="";
	//TRKr=top.document.referrer;
	//if ((TRKr == "") || (TRKr == "[unknown origin]") || (TRKr == "unknown") || (TRKr == "undefined"))
	//	if (document["parent"] != null) 
	//		if (parent["document"] != null)
	//			if (parent.document["referrer"] != null) 
	//				if (typeof(parent.document) == "object")
	//					TRKr=parent.document.referrer;
	//if ((TRKr == "") || (TRKr == "[unknown origin]") || (TRKr == "unknown") || (TRKr == "undefined"))
	//	if (document["referrer"] != null) 
	//		TRKr = document.referrer;
	TRKscreen=screen.width+"x"+screen.height;
	if (navigator.appName != "Netscape") {TRKcdi=screen.colorDepth}
	else {TRKcdi=screen.pixelDepth};
	TRKjava=navigator.javaEnabled();
	TRKusercode=awstats_getCookie("UserCode");
	TRKsessioncode=awstats_getCookie("SessionCode");
	var TRKrandomnumber=Math.floor(Math.random()*10000);
	if (TRKusercode == null || (TRKusercode=="")) {TRKusercode = "UserCode" + TRKnow.getTime() +"r"+ TRKrandomnumber};
	if (TRKsessioncode == null || (TRKsessioncode=="")) {TRKsessioncode = "SessionCode" + TRKnow.getTime() +"r"+ TRKrandomnumber};
	awstats_setCookie("UserCode", TRKusercode, 10000);
	awstats_setCookie("SessionCode", TRKsessioncode, 1);
	TRKusercode=""; TRKusercode=awstats_getCookie("UserCode");
	TRKsessioncode=""; TRKsessioncode=awstats_getCookie("SessionCode");
	
	var TRKagt=navigator.userAgent.toLowerCase();
	var TRKie  = (TRKagt.indexOf("msie") != -1);
	var TRKns  = (navigator.appName.indexOf("Netscape") != -1);
	var TRKwin = ((TRKagt.indexOf("win")!=-1) || (TRKagt.indexOf("32bit")!=-1));
	var TRKmac = (TRKagt.indexOf("mac")!=-1);
	
	if (TRKie && TRKwin) {
		var TRKshk = awstats_detectIE("SWCtl.SWCtl.1")
		var TRKfla = awstats_detectIE("ShockwaveFlash.ShockwaveFlash.1")
		var TRKrp  = awstats_detectIE("rmocx.RealPlayer G2 Control.1")
		var TRKmov = awstats_detectIE("QuickTimeCheckObject.QuickTimeCheck.1")
		var TRKwma = awstats_detectIE("MediaPlayer.MediaPlayer.1")
		var TRKpdf = awstats_detectIE("PDF.PdfCtrl.5");
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
	document.write('<img src="'+awstatsmisctrackerurl+'?SCREEN='+TRKscreen+'&CDI='+TRKcdi+'&JAVA='+TRKjava+'&UC='+TRKusercode+'&SC='+TRKsessioncode+'&SHK='+TRKshk+'&FLA='+TRKfla+'&RP='+TRKrp+'&MOV='+TRKmov+'&WMA='+TRKwma+'&PDF='+TRKpdf+'" height=0 width=0 border=0>')
	// Removed '&ICON='+icon+'&R='+escape(TRKr)

}
