;var NetTalkVersion=12.63
// ---------------------------------------------
var sessionManagerId='';
var cnt=0;
var tcnt=0;
var fcnt='';
var icnt='';
var ntMultiTab=false;

function initTabID(){
	ntMultiTab=true;
	var newId=false;
	var ce=false;
	if (!sessionStorage.id || localStorage.newIdRequired == 1){
		// we don't have a tab id yet
		localStorage.newIdRequired = 0;
		sessionStorage.id = Math.random().toString(36).substr(5);		
		newId = true;
	} else {
		if (document.cookie.indexOf('x-TabID=') < 0){
			// the server doesn't know our TabId, so we need to send it.
			newId = true;
		}	
	}

	// for ajax calls no cookie is used - rather the x-TabID header is set to the current session storage ID.
	$.ajaxSetup({
		headers: { 'x-TabID': sessionStorage.id }
	});	
	
	if (newId){
		if (localStorage.fromTabId){
			$.get('NewTabID'+ntdExt,'_ajax_=1&x-FromTabID=' + localStorage.fromTabId,function(data){xmlProcess(data);reload();});
		} else {
			$.get('NewTabID'+ntdExt,'_ajax_=1',function(data){xmlProcess(data);reload();});
		}	
	}	
	
	// can't change headers for a non-ajax request. 
	// these cookies are "fleeting" so clear them away.
	document.cookie = 'x-TabID=; expires=Thu, 01-Jan-70 00:00:01 GMT;';	// want to leave this cookie in play so to support F5 on addrss bar
																			// not sure if this will have adverse effects elsewhere though. In testing, seems ok.
	document.cookie = 'x-FromTabID=; expires=Thu, 01-Jan-70 00:00:01 GMT;';	
	localStorage.fromTabId = '';
	
	// mouse could be left, right or middle... so set FromTabId preemptivly.
	$('a').mousedown(function (event) { 
		localStorage.fromTabId = sessionStorage.id;
	}); 
	// a Ctrl-Click, or right-click/new tab or whatever does NOT go through this code. which is why FromTabID is set on MouseDown
	$('a').click(function (event) {		
		if (event.metaKey || event.ctrlKey || $(this).attr('target') == '_blank'){ 	// going to a new tab
		} else {  																	// normal click, so want TabID Cookie
			setTabIdCookie()
		}		
	});  
	// F5 in a browser, should set the tabid cookie
	// This traps F5 on the _page_ but does not trap F5 on the Address bar.
	$(document).on("keydown", function(e){
		if (e.which == 116 || e.keyCode == 116){
			setTabIdCookie()
		}
	});
	initTabIDButtons();
};

function reload(){
	setTabIdCookie()
	location.reload();
}

function initTabIDButtons(){	
	// set anything that has a data-tabid attribute
	$('[data-tabid]').keydown(function(event){initTabIDWorker();}).mousedown(function (event) {initTabIDWorker();}); 
	// setting on button click appears to be too late, so set on button down.
	$('button').mousedown(function (event) {initTabIDWorker();}).keydown(function(event){initTabIDWorker();});  
	$('input[type="submit"]').mousedown(function (event) {initTabIDWorker();}).keydown(function(event){initTabIDWorker();});  
	$('input[type="button"]').mousedown(function (event) {initTabIDWorker();}).keydown(function(event){initTabIDWorker();});  
	$('input[type="image"]').mousedown(function (event) {initTabIDWorker();}).keydown(function(event){initTabIDWorker();});  
	$('input[type="reset"]').mousedown(function (event) {initTabIDWorker();}).keydown(function(event){initTabIDWorker();});  
};

function initTabIDWorker(){
	var t= $(this).attr('target');
	var oc = $(this).attr('onclick');
	if (oc){
		oc = oc.indexOf("'_blank'");
	} else {
		oc = -1;
	}
	if (t == '_blank' || oc >= 0){
		localStorage.fromTabId = sessionStorage.id;
		localStorage.newIdRequired = 1;
	} else {
		setTabIdCookie();
	}		
};

function setTabIdCookie(){
	if (location.protocol === 'https:') {
		document.cookie = 'x-TabID=' + sessionStorage.id + '; secure';
	} else {
		document.cookie = 'x-TabID=' + sessionStorage.id + ';';
	}  
}

function getTabId(){
  return(sessionStorage.id)
}

function countDown(){
  hh = parseInt( cnt / 3600 );
  mm = parseInt( cnt / 60 ) % 60;
  ss = cnt % 60;
  if(hh){
    var t = ' ' + hh + ":" + (mm < 10 ? "0" + mm : mm) + ":" + (ss < 10 ? "0" + ss : ss);
  }	else {
    var t = ' ' + (mm < 10 ? "0" + mm : mm) + ":" + (ss < 10 ? "0" + ss : ss);
  }
  jQuery('#' + icnt).html(t);
  cnt -= 1;
  if (cnt ==0){
    window.open(fcnt,'_top');
  } else {
        setTimeout("countDown();",1000);
  }
};

function resetCountDown(){
	cnt = tcnt;
	if (sessionManagerId) {
		$(sessionManagerId).ntsessionmanager("resetCountDown")
	}
}

function startCountDown(t,f,i){
  if (t){
        tcnt = t;
    }
    if (f){
        fcnt = f;
    }
    if (i){
        icnt = i;
    }
    cnt = tcnt;
  countDown();
};

function versionCheck(v){
  var s = v + '';
  s = s.replace('.','');
  v = Number(v);
  if (v != NetTalkVersion){
    $('#_ver' + s).html('UPDATE OF WEB FOLDER REQUIRED - Try pressing Ctrl-F5. Server is on version ' + v + ' but web folder is on version ' +  NetTalkVersion);
	//window.location.reload(true);  // what happens if the server folder has not been updated though?
  } else {
        $('#_ver' + s).hide();
    }
}

function showInfo(m,t,d){
  if (!d){
    d = 'alert_div';
  }
  $('#'+d).html(m).hide().fadeIn(1000);
  if (t){
    setTimeout("hideInfo('"+d+"');",t);
  }
}
    
function hideInfo(d){    
  if (!d){
    d = 'alert_div';
  }
  $('#'+d).show().fadeOut(1000,function(){$('#'+d).html('')});
}  

function getScreenSize(force){
	if (force==true || sessionStorage._ScreenWidth_ != $(window).width() || sessionStorage._ScreenHeight_ != $(window).height()){
		sessionStorage._ScreenWidth_ = $(window).width();
		sessionStorage._ScreenHeight_ = $(window).height();
		$.get('SetSessionValue'+ntdExt,'_ScreenWidth_=' + $(window).width() + '&_ScreenHeight_=' + $(window).height() + '&_ajax_=1',function(data){xmlProcess(data);});
	}	
}

// ---------------------------------------------
// functions to handle busy graphic
var busyCounter=0;
$(document).ready(function() {
	busyCounter = 0;
	$("#_busy").hide(); 
	$(document).on("ajaxSend",function(event){
		$("#_busy").css('left',event.pageX).css('right',event.pageY);
		$("#_busy").show();
		busyCounter += 1;
		if (window.attachEvent && !window.addEventListener) { // detects IE8 and below
			$('input:radio, input:checkbox').off('click.iefix');
		};
	});
	$(document).on("ajaxComplete",function(){;
		if (busyCounter){busyCounter -= 1;}
		if (busyCounter ==0){ $("#_busy").hide(); };
		if (window.attachEvent && !window.addEventListener) { // detects IE8 and below
			$('input:radio, input:checkbox').on('click.iefix',function () {
				this.blur();
				this.focus();
			});
		}
	});
});
// ---------------------------------------------
function ntConfirm(m,t,b1,b2,f,p1,p2,p3){
	if (mobilemode){
		f(p1,p2,p3);
		return;
	}
	setTimeout(function(){
        var a = jQuery(":focus").attr('id');
		$("#message_alert").remove();
        if (t){
			$('body').append('<div id="message_alert" title="' + t + '">' + m + '</div>');
		} else {	
			$('body').append('<div id="message_alert" title="Alert">' + m + '</div>');
		}	
		$("#message_alert").dialog({
			resizable: false,
			modal: true,
			buttons: [	{			
				text: b1,
				click: function() {
					$(this).dialog("close");
					$("#message_alert").remove();
					f(p1,p2,p3);
				} }, {
				text: b2,
				click: function() {
					$(this).dialog("close");
					$("#message_alert").remove();					
				} } 				
			],
			open: function() {
				 $(this).parent().find('button:nth-child(1)').focus(); 
			},
			close: function() {
				 $('#' + a).focus();  
			}
		});		
    }, 1);
};
// ---------------------------------------------
function ntAlert(message,title,timer,oktext,css){
	if(!oktext){oktext = 'OK'}
	if(!title){title = 'Alert'}
	if(css){
		var cssDialog = 'nt-' + css + '-dialog'
		var cssButton = 'nt-' + css + '-button'
	}
	setTimeout(function() {
        var a = jQuery(":focus").attr('id');
		$("#message_alert").remove();
		$('body').append('<div id="message_alert" title="' + title + '">' + message + '</div>');
		$("#message_alert").dialog({
			classes: {"ui-dialog": cssDialog},
			resizable: false,
			modal: true,
			width: "500px",
			buttons: [{
				text: oktext,
				class: "ui-button " + cssButton,
				click: function() {
					$(this).dialog("close");
					$("#message_alert").remove();
				}
			}],
			open: function() {
				 $(this).parent().find('button:nth-child(1)').focus(); 
			},
			close: function() {
				 $('#' + a).focus();  
			}
		});
		if (timer){
			setTimeout(function() { $("#message_alert").dialog("close"); }, timer);
		}
    }, 1);
}
// ---------------------------------------------
var hadfocus='';
var setfocus='';
function afterSv(){
  GreenAll();
}

var tables = [];
function GreenAll(){
  for(var e = 0; e < tables.length; e++){
     tables[e].table=document.getElementById(tables[e].tid); // necessary after ajax call
     if (tables[e].table != null){
       tables[e].parseCell();
       tables[e].applyGreenBar();
     }
     tables[e].makeResizable();
     tables[e].prepColumns();
     tables[e].bind();
     //tables[e].restoreFocus();
  }
}
// -----------------------------------------------------------------------------------
// AutoTab support
// If an entry field has data-nt-autotab=1", then when the maxlength is reached focus
// automatically moves to the next field.
// -----------------------------------------------------------------------------------
jQuery.fn.focusNextInputField = function() { // this function from http://jqueryminute.com/, thanks to jdSharp.
    return this.each(function() {
        var fields = $(this).parents('form:eq(0),body').find('button,input,textarea,select').not('[readonly]');
        var index = fields.index( this );
        if ( index > -1 && ( index + 1 ) < fields.length ) {
            fields.eq( index + 1 ).focus();
        }
        return false;
    });
};

// recursive function to find the first checkbox which is "inside" c.
function getCheckbox(c){
 if (c.type == 'checkbox'){
  return c;
 }
 if (c.firstChild != null){
  a = getCheckbox(c.firstChild);
  if (a != null){
  return a;
  }
 }
 while (c.nextSibling != null){
  a = getCheckbox(c.nextSibling);
  if (a != null){
   return a;
  }
 }
 return null;
}

function dsb(event,f,b,n,prid,prv){
 var i=0;
 if (n=='deleteb_btn'){
  if(confirm('Are you sure you want to delete this record?')==false){
   return false;
  }
 }
 // dont send files if form is cancelled.
 if (n=='cancel_btn'){
                jQuery(':file').remove();
 }
 // set all buttons disabled, if target of button is same frame.
 if (f.target == "" || f.target == "_self"){
         jQuery(':button').attr('disabled', 'disabled');
 }
 for (var e=0 ; e < f.elements.length; e++) {
   if (f.elements[e].name == prid){
    f.elements[e].value = prv;
    i = 1;
   }
 }
 var bid = document.createElement('INPUT');
 bid.type = 'hidden';
 bid.name = '_buttontext_';
 bid.value = $(event.target).closest("button").val();
 f.appendChild(bid);

 jQuery("#_webkit_").val(Math.random());
 if ((i==0) && (prid != '')){
  var rid = document.createElement('INPUT');
  rid.type = 'hidden';
  rid.name = prid;
  rid.value = prv;
  f.appendChild(rid);
 }
 var pb = document.createElement('INPUT');
 pb.type = 'hidden';
 pb.name = 'pressedButton';
 pb.value = n;
 f.appendChild(pb);
 osf(f);
 f.submit();
}

function osf(f){
    if(f.target=='' || f.target=='_self' || f.target=='_top') {
        for (var e=0 ; e < f.elements.length; e++) {
            if(f.elements[e].type=='button'){
                f.elements[e].disabled = true;
            }
        }
    }
}

function ml(ta,ml,e){
	var k;
	if(window.event){ // IE
		k = e.keyCode
	} else if(e.which){ // Netscape/Firefox/Opera/Safari
		k = e.which
	};
	switch(k){
	case 8: // backspace
	case null:
	case undefined:  // del
	case 120: // ctrl-x
		return true		
	case 118: // ctrl-v
		break;
	}	  
	if (k > 60000){
		return true;
	}
	return (ta.value.length <= ml);
}

function firstFocus(id){
  var e;
  var t = 4000000000;
    jQuery(id + ' :input').not('[readonly],[disabled],[type="hidden"]').each(function(){
      tx = $(this).offset().top
      if (tx+1 < t && tx != 0){  // +1 to handle lookup buttons that are 1 pixel higher than the textarea field.
        e = this;
        t = tx;
      }
    })
    $(e).focus();
}

function nextFocus(f,pname,skipone){
  var i = 0;
  var j = 0;
  if (skipone==2){ // pname is specified control to get focus
    for (var e=0 ; e < f.elements.length; e++) {
      if(f.elements[e].name==pname){
  try{
    f.elements[e].focus();
  } catch (e) {
  }
  break;
      }
    }
  } else {
    for (var e=0 ; e < f.elements.length; e++) {
      if (i==1){
  if ((f.elements[e].type == "text") || (f.elements[e].type == "textarea") || (f.elements[e].type == "checkbox") || (f.elements[e].type == "radio") || (f.elements[e].type == "select-one")){
    //|| (f.elements[e].type == "button")
    if(f.elements[e].readOnly != true){
      if((skipone==1) && (j==0)){
        j = 1;
      } else {
        try{
    f.elements[e].focus();
        } catch (e) {
        }
        break;
      }
    }
  }
      }
      else{
  if(pname==''){
    if(f.elements[e].readOnly != true){
      try{
        f.elements[e].focus();
      } catch (e) {
      }
      break;
    }
  } else {
    if(f.elements[e].name==pname){
      i = 1;
    }
  }
      }
    }
  }
}


function removeElement(fn,dn){
 var f=document.getElementById(fn);
 var dv=document.getElementById(dn);
 var a;
 var b;
 if (dv != null){
  var divs = dv.getElementsByTagName('DIV');
  for(var e = divs.length-1; e>=0 ; e--){
   if ((divs[e].id != dn) && (divs[e].id != '')){
    removeElement(fn,divs[e].id);
   }
  }
  if (f != null){
   for(var e = f.elements.length-1; e>=0 ; e--) {
    a = f.elements[e].parentNode.id;
    b = dv.id
    if (a==b){
     try{
      dv.removeChild(f.elements[e]);
     } catch (e) {
     }
    }
   }
  }
 }
}

function FieldValue(f,e){
  var ans ='';
  var typ = f.type;
  var i = 0;
  var j = 0;
  if (typ == undefined){
	if(f[0]){
		typ = f[0].type;
	}
  }
  switch (typ){
  case "radio":
    j = f.length;
    for(i = 0; i < j; i++) {
      if(f[i].checked) {
		ans = f[i].value;
		break;
      }
    }
    break;
  case "checkbox":
	if (f.checked){
		ans = $(f).attr("data-true");
		if(ans===undefined){
			ans = f.value;
		}
	} else {
		ans = $(f).attr("data-false");
		if(ans===undefined){
			ans = 0;
		}			
	}
    break;
  case "select-multiple":
    j = f.length;
    for(i = 0; i < j; i++) {
      if(f.options[i].selected) {
        ans = ans + ';|;' + f.options[i].value;
    }
    }
    break;
  default:
    if ($(f).data('luv')){
      ans = $(f).data('luv');
    } else {
      ans = f.value;
    }
  }
  // if called as a post, do not encode & and %. If called from EIP then do.
  if ((typeof(ans)=='string') && (ans != undefined) && ((e == 0) || (e == undefined))){
                ans = ans.replace(/%/g,"%25");
                ans = ans.replace(/&/g,"%26");
                ans = ans.replace(/#/g,"%23");
				ans = ans.replace(/\+/g,"%2B");
        }
  return ans
}

function SetSessionValue(name,value){
	$.get('SetSessionValue'+ntdExt,name+'='+value+'&_ajax_=1',function(data){xmlProcess(data);});
}

function TabChanged(url,value){
	$.get(url+ntdExt,'_tab_='+value+'&_ajax_=1',function(data){xmlProcess(data);});
}

function aGet(url,parms){
	$.get(url+ntdExt,parms+'&_ajax_=1&_cb_='+url,function(data){xmlProcess(data);ntWidth();});
}

function GetTab(name){
	$.get(name+ntdExt,'_ajax_=1',function(data){xmlProcess(data);});
}

function xmlProcess(data,processString){
	if ((typeof(data) == 'string') && (processString != true)) {
		$('html').trigger("ajaxComplete");
		return;
	}
	$('response',data).each(function(i){
		var elem = $("response",data).get(i); // returns Element object
		var type = $(elem).attr("type");

		if (window.ActiveXObject) {  //for IE
			var s = elem.xml;           // IE 9 doesn't get this
			if (s == undefined){
				var s = (new XMLSerializer()).serializeToString(elem); // but IE9 can do this, which IE7/8 can't
			}
		} else { // code for Mozilla, Firefox, Opera, etc.
			var s = (new XMLSerializer()).serializeToString(elem);
		}
		if (s){
			s = s.substring(s.indexOf('>')+1,s.lastIndexOf('<'));
			if (type=='element'){
				d = $(elem).attr("id");
				$("#"+d).replaceWith(s);
				try{$("#"+d).page().removeClass("ui-page").css('border',0);} catch(e){};
			} else if (type=='script'){
				s = s.replace(/&quot;/g,'"');
				s = s.replace(/&amp;/g,"&");
				s = s.replace(/&lt;/g,"<");
				s = s.replace(/&gt;/g,">");
				s = s.replace(/&apos;/g,"'");
				try{
				eval(s);
				} catch (err){
					try{
					} catch (err){}
				}
			}
		}
	});
	afterSv();
	if (ntMultiTab){
		initTabIDButtons();
	}
    gradient();
    resetCountDown();
}

// SetServer
function sv(id,name,ev,val,par,sil){
	hadfocus = id;
	if(par==undefined){
		$.get(name+ntdExt,{_event_: ev,value: val,_ajax_:1, _rnd_: Math.random()},function(data){xmlProcess(data);});
	}else{
		var parms='';
		for(var d = 2; d < arguments.length; d++){
			parms += arguments[d] + '&';
		}
		parms += '_ajax_=1&_rnd_=' + Math.random();
		$.get(name+ntdExt,parms,function(data){xmlProcess(data);});
	}
}

//Set timer
function SetTimer(name,t,par,sil){
	if(par==undefined)  {par='fred=1'};
	if(sil==undefined)  {sil='fred=2'};
	setTimeout("sv('','"+name+"','','','"+par+"','"+sil+"');",t);
};

// SelectDate and ResetAfterDate called by Date Lookup button
var cr1;
var cs;
var ct;
var cb1;
var cb2;
// SelectDate
function sd(f,e,p,r,b1,b2){
 ct = document.forms[f].elements[e];
 switch (p){
 case "@D6":
 case "@D06":
  var c = new calendar6(ct);
  break;
 case "@D2":
 case "@D02":
  var c = new calendar2(ct);
  break;
 }
 c.popup();
 if (arguments.length == 4){
  cr1 = r;
  cs = 1;
 }
 if (arguments.length == 6){
  cr1 = r;
  cs = 2;
  cb1 = b1;
  cb2 = b2;
 }
}

// jQuery Default Settings
jQuery.datepicker.setDefaults({
   closeText: 'Cancel',
   dateFormat: 'm/dd/yy',
   showButtonPanel: true,
   showOn: 'nothing',
   buttonImageOnly: true,
   buttonImage: '/styles/images/calendar.gif',
   buttonText: 'Calendar',
   constrainInput: false
});
function bubbleStyle(div,attr,col){
    if ((attr=='background-color') && (col != 'transparent')){
		$("#"+div).parent().css('background-color',col);
        $("#"+div).css('background-color','transparent');
        $("#"+div).parent('[class~="nt-grad"]').each(function(){
			if (Modernizr.cssgradients ==  false){
				if (window.ActiveXObject) {  //for IE
					var ua = navigator.userAgent;
					var re  = new RegExp("MSIE ([0-8]{1,}[\.0-8]{0,})");
					if (re.exec(ua) != null){
						$("#"+div).parent().each(function(){
							this.style.filter = '"filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='+col+', endColorstr=#FFFFFFFF)"';
						});
					}
				}
			} else {

				$(this).css('background','linear-gradient(to top, #FFFFFF 0%, '+col+' 75%)');
				//$("#"+div).parent().css('background','-webkit-gradient(linear, 0 0, 0 100%, from('+col+'), to(#FFFFFF))');
				//if ($("#"+div).parent().css('background') == ''){
				//	$("#"+div).parent().css('background','-moz-linear-gradient(center bottom, #FFFFFF 0%, '+col+' 75%)');
				//}


			}
		});
    }
}

function gradient(){
	$('.nt-grad').each(function(){
		var col = $(this).css('background-color');
		if ((col != 'transparent') && (col != 'rgba(0, 0, 0, 0)')){
			if (Modernizr.cssgradients ==  false){
				if (window.ActiveXObject) {  //for IE
					var ua = navigator.userAgent;
					var re  = new RegExp("MSIE ([0-8]{1,}[\.0-8]{0,})");
					if (re.exec(ua) != null){
						this.style.filter = '"filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='+col+', endColorstr=#FFFFFFFF)"';
					}
				}
			} else {
				$(this).css('background','linear-gradient(to top, #FFFFFF 0%, '+col+' 75%)');			
				//$(this).css('background','-webkit-gradient(linear, 0 0, 0 100%, from('+col+'), to(#FFFFFF))');
				//if ($(this).css('background') == ''){
				//	$(this).css('background','-moz-linear-gradient(center bottom, #FFFFFF 0%, '+col+' 75%)');
				//}
			}
        }
	});
}

// ---------------------------------------------
function browseCssSupport(){
// $('body').prepend('<div id="_ntbc_" class="nt-browse-colors"></div>');
}

// ---------------------------------------------
// run html5 support scripts when page opens
jQuery(document).on('ready', function(event) {
	gradient();
    browseCssSupport();
});
// ---------------------------------------------
// IE checkbox / radio fix for IE <= 8
// http://norman.walsh.name/2009/03/24/jQueryIE
$(function () {
	if (window.attachEvent && !window.addEventListener) { // detects IE8 and below
        $('input:radio, input:checkbox').on('click.iefix',function () {
            this.blur();
            this.focus();
        });
    }
});


// ---------------------------------------------
//  Extension of jQueryUi dialog to add a call to SetAccess
// ---------------------------------------------
(function(jQuery){
    var _init = jQuery.ui.dialog.prototype._init;

    //Custom Dialog Init
    jQuery.ui.dialog.prototype._init = function() {
        _init.apply(this, arguments);
        var _this=this;
    if ((this.options.addsec != '') && (this.options.addsec != undefined)){
            tb = this.uiDialogTitlebar;
            tb.append('<a href="#" id="dialog-access" class="ui-dialog-titlebar-close dialog-access ui-dialog-titlebar-access ui-corner-all nt-dialog-titlebar-secwin"><span class="ui-icon ui-icon-key nt-sec-icon-key"></span></a>');
            //Secwin Button
            jQuery('.dialog-access', tb).hover(function(){
                jQuery(this).addClass('ui-state-hover');
            }, function(){
                jQuery(this).removeClass('ui-state-hover');
            }).click(function(){
                ntd.push('secwinwebuseraccess','','header',1,2,null,'','','_screen_=' + _this.options.addsec);
                return false;
            });
        }
    };

})(jQuery);


function swpf(id,addsec){
	$('#form-access-'+id).prepend('<a href="#" id="a-form-access-'+id+'" class="nt-form-page-access ui-widget-header ui-corner-all"><span class="ui-icon ui-icon-key"></span></a>');
	$('#a-form-access-'+id).hover(function(){
		$(this).addClass('ui-state-hover');
	}, function(){
		$(this).removeClass('ui-state-hover');
	}).click(function(){
		ntd.push('secwinwebuseraccess','','header',1,2,null,'','','_screen_=' + addsec);
		return false;
	});
}

function primeLocation(pLat,pLong,pAlt,pAcc,pAltAcc,pHeading,pSpeed,pDiv){
	if (pDiv){
		$(pDiv).html('Getting position')
	}
	var watchId = navigator.geolocation.watchPosition(
		function(pos){ // location found
			navigator.geolocation.clearWatch(watchId);
			$(pLat).val(pos.coords.latitude);
			$(pLong).val(pos.coords.longitude);
			$(pAlt).val(pos.coords.altitude);
			$(pAcc).val(pos.coords.accuracy);
			$(pAltAcc).val(pos.coords.altitudeAccuracy);
			$(pHeading).val(pos.coords.heading);
			$(pSpeed).val(pos.coords.speed);
			if (pDiv){
				$(pDiv).html('Position:' + pos.coords.latitude.toString().substring(0,7) +',' + pos.coords.longitude.toString().substring(0,7))
			}
			
		},
		function(err){ // location not found
			switch(err.code){
				case err.PERMISSION_DENIED: 
					//debug('Device Location: Permission Denied')
					$(pDiv).html('Location: Permission Denied')
					break;
				
				case err.POSITION_UNAVAILABLE: 
					//debug('Device Location: Position Unavailable')
					$(pDiv).html('Location: Permission Unavailable')
					break;
					
				case err.TIMEOUT: 
					//debug('Device Location: Timeout')
					$(pDiv).html('Location: Permission Timeout')
					break;
					
				default: 
					//debug('Device Location: Unknown Error: ' + err.code)
					$(pDiv).html('Location: Unknown Error: ' + err.code)
				break;
			}
		},
		{ enableHighAccuracy: false, timeout: 30000,maximumAge: 300000 }		
		);


	navigator.geolocation.getCurrentPosition(
		function(pos){ // location found
			//debug('location found ' + pos.coords.latitude +  ',' + pos.coords.longitude + ' pDiv=' + pDiv)
			$(pLat).val(pos.coords.latitude);
			$(pLong).val(pos.coords.longitude);
			$(pAlt).val(pos.coords.altitude);
			$(pAcc).val(pos.coords.accuracy);
			$(pAltAcc).val(pos.coords.altitudeAccuracy);
			$(pHeading).val(pos.coords.heading);
			$(pSpeed).val(pos.coords.speed);
			if (pDiv){
				$(pDiv).html('Position:' + pos.coords.latitude.toString().substring(0,7) +',' + pos.coords.longitude.toString().substring(0,7))
			}
		},
		function(err){ // location not found
			switch(err.code){
				case err.PERMISSION_DENIED: 
					//debug('Device Location: Permission Denied')
					$(pDiv).html('Location: Permission Denied')
					break;
				
				case err.POSITION_UNAVAILABLE: 
					//debug('Device Location: Position Unavailable')
					$(pDiv).html('Location: Position Unavailable')
					break;
					
				case err.TIMEOUT: 
					//debug('Device Location: Timeout')
					$(pDiv).html('Location: Timeout')
					break;
					
				default: 
					//debug('Device Location: Unknown Error: ' + err.code)
					$(pDiv).html('Location: Unknown Error: ' + err.code)
				break;
			}

		},
		{ enableHighAccuracy: false, timeout: 30000,maximumAge: 300000 }		
		);
}

function getLocation(){
	navigator.geolocation.getCurrentPosition(sendLocation,noSendLocation);
}

function sendLocation(pos){
	$.get('SetSessionValue'+ntdExt,'_Latitude_=' + pos.coords.latitude +
                               '&_Longitude_=' + pos.coords.longitude +
                               '&_Altitude_=' + pos.coords.altitude +
                               '&_Accuracy_=' + pos.coords.accuracy +
                               '&_AltitudeAccuracy_=' + pos.coords.altitudeAccuracy +
                               '&_Heading_=' + pos.coords.heading +
                               '&_Speed_=' + pos.coords.speed +
                               '&_LocationUnixTime_=' + parseInt(pos.timestamp/1000) +
                               '&_LocationDate_=' + parseInt(pos.timestamp / 86400000 + 61730) +
                               '&_LocationTime_=' + parseInt((pos.timestamp % 86400000) / 10) +
                               '&_LocationError_=' +
                               '&_ajax_=1'
         ,function(data){xmlProcess(data);});
}

function noSendLocation(err){
	switch(err.code){
		case err.PERMISSION_DENIED: 
			SetSessionValue('_LocationError_',err.code + '_permission_denied');
			debug('Location: Permission Denied')
			break;
		
		case err.POSITION_UNAVAILABLE: 
			SetSessionValue('_LocationError_',err.code + '_position_unavailable');
			debug('Location: Position Unavailable')
			break;
			
		case err.TIMEOUT: 
			SetSessionValue('_LocationError_',err.code + '_timeout');
			debug('Location: Timeout')
			break;
			
		default: 
			SetSessionValue('_LocationError_',err.code + '_unknown');
			debug('Location: Unknown Error: ' + err.code)
			break;
	}
};

function ntPlay(soundfile){
	var audio = document.createElement('audio');
	audio.src=soundfile;
	audio.play();
	audio.onended = function(){
		audio.remove(); //remove after playing to clean the Dom
	};
};

function ntWidth(){
	$('#body_div').css('min-width',$('#contentbody_div').outerWidth(true) + $('.nt-menuleft:first').outerWidth(true) +20);
}

//------------------------------------------------------------------------------
function consoleLog(s){
  //$('#consolelog').append(s + '<br/>')
}
//------------------------------------------------------------------------------
// returns date in Clarion Date format. Default is local time (of the browser), pass 1 in parameter to get utc time.
function clarionToday(utc){ 
  time = Date.now()/10;
  if (!utc){
    d = new Date();
    time -= d.getTimezoneOffset()*6000
  } 
  return (parseInt(time / 8640000) + 61730)	  
}
//------------------------------------------------------------------------------
// returns local date/time in unix millisecond format.
function localTime(){ 
  time = Date.now();
  d = new Date();
  time -= d.getTimezoneOffset()*60000
  return (time)	  
}
//------------------------------------------------------------------------------
// returns time in Clarion time format. Default is local time (of the browser), pass 1 in parameter to get utc time.
function clarionClock(utc){
  time = Date.now()/10;
  if (!utc){
    d = new Date();
    time -= d.getTimezoneOffset()*6000
  }  
  return (parseInt(1+(time % 8640000)))
}
//------------------------------------------------------------------------------
function today(pic){
	var p=0;
	var td = new Date(); // primed with current date and time utc
	return formatDate(td,pic);
}
//------------------------------------------------------------------------------
function clock(pic){
	var td = new Date();
	return formatTime(td,pic);
}	
//------------------------------------------------------------------------------
function formatDate(value,pic){
	const shortMonthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
	const longMonthNames = ["January", "February", "March", "April", "May", "June","July", "August", "September", "October", "November", "December"];
	var zero=false;
	var separatorChar = '/';
	var p=0;
	if (typeof(value)=='number'){
		if(value < 100000){// clarion date value
			value = new Date(ClarionToUnixDate(value,localTime())*1000);
		} else {
			value = new Date(value);		
		} 
	}
	if (typeof(value)=='object'){
		var dd = value.getDate();
		var mm = value.getMonth()+1; //January is 0!
		var yyyy = value.getFullYear();
	}
	if (!pic){
		p = 1;
	} else { // default to mm/dd/yyyy
		if (pic.charAt(0) == '@'){
			pic = pic.substring(1) // remove leading @
		}
		if (pic.charAt(0) == 'D' || pic.charAt(0) == 'd'){
			pic = pic.substring(1) // remove leading D or d
		}
		if (pic.charAt(0) == '0'){
			zero = true;
		}
		p = parseInt(pic);
		if ( p < 1){ p = 1};
	}	
	switch(p){
	case 1: // mm/dd/yyyy
		yyyy = yyyy % 100
		// drop down to 2 and keep going
	case 2: 
		if (zero){
			if(mm<10) { mm='0'+mm} 			
		}
		if(dd<10) {	dd='0'+dd} 
		value = mm + separatorChar + dd + separatorChar + yyyy;
		break;
	case 3:
		value = shortMonthNames[mm-1] + ' ' + dd  + ', ' + yyyy
		break;
	case 4: 
		value = longMonthNames[mm-1] + ' ' + dd  + ', ' + yyyy
		break;
	case 5: 
		yyyy = yyyy % 100
	case 6: 
		if (zero){
			if(dd<10) {	dd='0'+dd} 
		}
		if(mm<10) { mm='0'+mm} 			
		value = dd + separatorChar + mm + separatorChar + yyyy;
		break;
	case 7: 
		yyyy = yyyy % 100
	case 8: 
		if (zero){
			if(dd<10) {	dd='0'+dd} 
		}	
		value =  dd + ' ' + shortMonthNames[mm-1] + ' ' + yyyy
		break;
	case 9: 
		yyyy = yyyy % 100
	case 10: 
		if(dd<10) {	dd='0'+dd} 
		if(mm<10) { mm='0'+mm} 			
		value = yyyy + separatorChar + mm + separatorChar + dd;
		break;
	case 11: 
		yyyy = yyyy % 100
	case 12: 
		if(dd<10) {	dd='0'+dd} 
		if(mm<10) { mm='0'+mm} 
		value = yyyy+mm+dd
		break;
	case 13: 
		yyyy = yyyy % 100
	case 14: 
		if (zero){
			if(mm<10) { mm='0'+mm} 			
		}	
		value = mm + separatorChar + yyyy
		break;
	case 15: 
		yyyy = yyyy % 100
	case 16: 
		if(mm<10) { mm='0'+mm}
		value = yyyy + separatorChar + mm
		break;
	default:
		if(dd<10) {	dd='0'+dd} 
		if(mm<10) { mm='0'+mm} 
		value = mm + separatorChar + dd + separatorChar + yyyy;
		break;
	}
	return value;
}
//------------------------------------------------------------------------------
function formatTime(value,pic){
	var zero=false;
	var p=0;
	if (typeof(value)=='number'){ 
		if (value < 8640010){ // clarion time value
			var hh = parseInt(value / 360000) 
			var mm = parseInt(value % 360000 / 6000) 
			var ss = parseInt(value % 6000)
		} else {
			value = new Date(value);
			var hh = value.getHours();  
			var mm = value.getMinutes();
			var ss = value.getSeconds(); 
		}
	} else if (typeof(value)=='object'){		
		var hh = value.getHours();  
		var mm = value.getMinutes();
		var ss = value.getSeconds(); 
	} else {
		return value;
	}	
	if(ss<10) {	ss = '0'+ss} 
	if(mm<10) { mm = '0'+mm} 
	if (!pic){
		p = 1; // default to @t1
	} else { 
		if (pic.charAt(0) == '@'){
			pic = pic.substring(1) // remove leading @
		}
		if (pic.charAt(0) == 'T' || pic.charAt(0) == 't'){
			pic = pic.substring(1) // remove leading D or d
		}
		if (pic.charAt(0) == '0'){
			zero = true;
		}
		p = parseInt(pic);
		if ( p < 1){ p = 1};
	}	
	if (zero){
		if(hh<10) {	hh='0'+hh} 
	}	
	switch(p){
	case 1: // hh:mm
		value = hh+':'+mm;
		break;
	case 2: // hhmm
		value = hh+''+mm
		break;
	case 3: // hh:mm xm
		if (hh>=12){
			if (hh>12) hh -= 12;
			value = hh+':'+mm + ' pm';
		} else {
			value = hh+':'+mm + ' am';
		}
		break;
	case 4: // hh:mm:ss
		value = hh+':'+mm+':'+ss;
		break;
	case 5: // hhmmss
		value = hh+''+mm+''+ss;
		break;
	case 6: // hh:mm:ss xm
		if (hh>=12){
			if (hh>12) hh -= 12;
			value = hh+':'+mm +':'+ss + ' pm';
		} else {
			value = hh+':'+mm +':'+ss+ ' am';
		}
		break;
	}
	return value;	
}
//------------------------------------------------------------------------------
function formatDateTime(value,pic){ 
	var pics = pic.split('@')
	return formatDate(value,pics[1]) + ' ' + formatTime(value,pics[2])
}
//------------------------------------------------------------------------------
function format(value,pic){
	if(typeof(value)=='string'){
		return value
	}	
	if (pic.charAt(0) == '@'){
		pic = pic.substring(1) // remove leading @
	}
	if (pic.charAt(0) == 'D' || pic.charAt(0) == 'd'){
		return formatDate(value,pic)
	}
	if (pic.charAt(0) == 'T' || pic.charAt(0) == 't'){
		return formatTime(value,pic)
	}
	if (pic.charAt(0) == 'U' || pic.charAt(0) == 'u'){
		return formatDateTime(value,pic)
	}
	return value
}
//------------------------------------------------------------------------------
function ClarionToUnixDate(pDate,pTime){
	var r=0;
	if (pDate > 61730){ // 61730 = date(1,1,1970)
		r = ((pDate-61730)*86400) -(-pTime / 100) //  ! 86400 = seconds in 1 day
	} else {
		r = pTime / 100 // convert to seconds
	}	
  return parseInt(r)
}
//------------------------------------------------------------------------------
function GetUserTimeOffset(){
	date = new Date();
	SetSessionValue('_UserTimeOffset_',date.getTimezoneOffset()) 
};

function debug(text){
	$("#debug").append(text + '<br/>') ;
	console.log(text);
}

function getUTCTime(){
 var t = new Date().getTime();
 return t;
}
function onlyDigits(text){
	if(text){
		text.replace(/[^0-9]/g, '');
	}
	return text;	
}
function autoHeightText(textarea){
	var text = $('#' + textarea).val();
    var matches = text.match(/\n/g); // // look for any "\n" occurences
    var breaks = matches ? matches.length : 2;
	$('#' + textarea).attr('rows',breaks + 2);
}
;
function makeUrlData(fields){
	var ans = ''
	$.each(fields,function(index,value){
		if ($('#'+value).val()){
			ans = ans + '&' + encodeURIComponent($($('#'+value)).attr('data-do')) +'=' + encodeURIComponent($('#'+value).val())
		}
	})
	ans = ans.substr(1) // removes the leading &
	return(ans)
}
function textToTextarea(text,textarea){
	text = text.replace(/&/g, "&amp;");
	text = text.replace(/</g, "&lt;");
	text = text.replace(/>/g, "&gt;");
	text = text.replace(/'/g, "&apos;");
	text = text.replace(/"/g, "&quot;");
	$('#' + textarea).html(text);
	autoHeightText(textarea);	
}
function toggleButton(elem,divId){
	$('#' + divId).toggle();
	if ($('#' + divId).is(':visible')){
		$(elem).html('-');
	} else {
		$(elem).html('+');
	}
}
function setCss(customProperty,value){
	document.documentElement.style.setProperty(customProperty,value);
	return 0;
}
function getCss(customProperty){
	return getComputedStyle(document.documentElement).getPropertyValue(customProperty)
}
// converts css value, like 2em or 15px into (integer) pixels.
function getPixels(val,elemId){
	if (val.indexOf('px')>0){
		return parseInt(val)
	} else if (val.indexOf('rem')>0){
		return parseFloat(getComputedStyle(document.documentElement).fontSize)
	} else if (val.indexOf('em')>0){ 
		var elem = document.getElementById(elemId);
		if (!elem){
			elem = document.documentElement
		}	
		return parseFloat(getComputedStyle(elem).fontSize) * parseInt(val);
	}
	return parseInt(val)
}

function reloadStylesheets() {
    var queryString = '?c=' + new Date().getTime();
    $('link[rel="stylesheet"]').each(function () {
        this.href = this.href.replace(/\?.*|$/, queryString);
    });
	return 0;
} 

function fullscreen(elem) {
	if (!elem){
		elem = document.querySelector("body");
	}	
	elem.requestFullscreen().catch(err => {
		console.log('Error attempting to enable full-screen mode: ');
	});
}

function notfullscreen() {
	document.exitFullscreen();
}

function toggleFullscreen(elem) {
	if (!document.fullscreenElement) {
		fullscreen(elem)  
	} else {
		notfullscreen()
	}
}
;
// the code below is necessary because the XMLSerializer in xmlProcess contracts empty nodes to the <span/> form, which
// jquery 3.5.0 does not like. Working to remove the call to XMLSerializer is desired.
var rxhtmlTag = /<(?!area|br|col|embed|hr|img|input|link|meta|param)(([a-z][^\/\0>\x20\t\r\n\f]*)[^>]*)\/>/gi;
jQuery.htmlPrefilter = function( html ) {
	return html.replace( rxhtmlTag, "<$1></$2>" );
};

function togglePasswordField(id) {   
  if($("#"+id).attr("type") === 'entry'){
    $("#"+id).attr("type","password")
  } else {
    $("#"+id).attr("type","entry")
  }
} 