/*
ntdialog object is a stack to manage popup dialogs
a single var called ntd is created for each page at the end of the declaration.
*/
function ntdialog(){
this.level=-1;
this.luf=new Array();
this.sf=new Array();
this.dlg=new Array();
this.pmt=new Array();
this.open=new Array();
this.action=new Array(); // 1=insert, 2=change, 3=delete, 4=copy, 5=view, 6=lookup, 100=browse, 101=form
this.calledfrom=new Array();
this.grandparent=new Array();
this.row=new Array();
this.other=new Array();
this.autosave=new Array();
this.oncomplete=new Array();
this.viewstate=new Array();
this.equate=new Array();
this.saved=new Array();
this.deleted=new Array();
this.parent=new Array();
this.browseid=new Array();
}
// ----
ntdialog.prototype.push = function (dlg,luf,pmt,run,action,sf,calledfrom,row,other,autosave,oncomplete,grandparent,viewstate,equate,par,browseid){
 this.level += 1;
 this.dlg[this.level] = dlg.toLowerCase();
 this.luf[this.level] = luf;//lookupfield
 this.pmt[this.level] = pmt;//title
 this.sf[this.level] = sf;//sortfield
 this.row[this.level] = row;//row id
 this.other[this.level] = other;//other parameters
 this.autosave[this.level] = autosave;
 this.saved[this.level] = 0;
 this.deleted[this.level] = 0;
 this.open[this.level] = 0;
 if (action == null){
   this.action[this.level] = 0;
 } else {
   this.action[this.level] = action;
 }
 if (oncomplete){
   this.oncomplete[this.level] = oncomplete;
 } else {
   this.oncomplete[this.level] = '';
 }

 if (viewstate){
   this.viewstate[this.level] = viewstate;
 } else {
   this.viewstate[this.level] = '';
 }

 if (equate){
   this.equate[this.level] = equate;
 } else {
   this.equate[this.level] = '';
 }

 this.calledfrom[this.level] = calledfrom;
 this.parent[this.level] = par;
 this.grandparent[this.level] = grandparent;
 this.browseid[this.level] = browseid;
 if (run == 1){
   this.run();
 }
}
// ----
ntdialog.prototype.current = function (){
  return this.dlg[this.level];
}
// ----
ntdialog.prototype.setRow = function (rowId){  
	this.row[this.level] = rowId;
}
// ----
ntdialog.prototype.getRow = function (){  
	return this.row[this.level];
}
// ----
ntdialog.prototype.run = function (){  
	var lvl = this.level;
	var _this = this;
	var _id = '#popup_'+this.dlg[this.level].toLowerCase()+'_div';
	var _lsid = '#'+this.dlg[this.level].toLowerCase()+'_div';
	//console.log('ntd Run id=' + _id + ' ntdLocalStorage=' + ntdLocalStorage + '  this.action[this.level]=' + this.action[this.level] + ' this.level=' + this.level + ' this.autosave=' + this.autosave[this.level])
	if (this.level>-1){
		if (this.autosave[this.level] != 1){
			if (!ntdLocalStorage){
				SetSessionValue('popup_'+this.dlg[this.level],1);                       
			}	
			//console.log('ntd confirmation dialog open')
			if (this.pmt[this.level]) {
				var t = $(_id).dialog( "option", "title")
				var part = t.substring(
					t.indexOf("'nt-dialog-title-text'>") + 22, 
					t.indexOf("</div>"));
				if (part){
					t.replace('>' + part + '<',this.pmt[this.level])
					$(_id).dialog( "option", "title", t );
				} else {
					$(_id).dialog( "option", "title", this.pmt[this.level] );
				}
			}	
			$(_id).dialog('open');
			try{$('#'+this.dlg[this.level] + '_frm').ntform('hide');} catch(e) {}			
			try{$('#'+this.dlg[this.level] + '_div').ntform('hide');} catch(e) {}
		}
		switch (this.action[this.level]){
		case 1: //insert
			if (ntdLocalStorage){
				try{$('#'+this.dlg[this.level] + '_frm').ntformls("populate",this.action[this.level]);} catch(e) {}
				try{$('#'+this.dlg[this.level] + '_div').ntformls("populate",this.action[this.level]);} catch(e) {}
			} else {
				$.get(this.dlg[this.level]+ntdExt,'_ajax_=1&pressedButton=insert_btn&_popup_=1&_bidv_='+this.row[this.level] + '&_calledfrom_=' + this.calledfrom[this.level] + '&' + this.other[this.level],function(data){xmlProcess(data);firstFocus(_id);});
			}	
			break;
		case 2: //change
			if (ntdLocalStorage){
				try{$('#'+this.dlg[this.level] + '_frm').ntformls("populate",this.action[this.level],this.row[this.level]);} catch(e) {}	
				try{$('#'+this.dlg[this.level] + '_div').ntformls("populate",this.action[this.level],this.row[this.level]);} catch(e) {}	
			} else {
				if (this.autosave[this.level] != 1){
					$.get(this.dlg[this.level]+ntdExt,'_ajax_=1&pressedButton=change_btn&_popup_=1&_bidv_='+this.row[this.level] + '&_calledfrom_=' + this.calledfrom[this.level] + '&' + this.other[this.level],function(data){xmlProcess(data);firstFocus(_id);});
				} else {
					$.get(this.dlg[this.level]+ntdExt,'_ajax_=1&pressedButton=change_btn&_popup_=1&_bidv_='+this.row[this.level] + '&_calledfrom_=' + this.calledfrom[this.level] + '&_auto_='+this.calledfrom[this.level]+'&_parentProc_=' + this.parent[this.level] + '&' + this.other[this.level],function(data){xmlProcess(data);firstFocus(_id);});
				}
			}	

			break;
//   	case 3: //delete
//    	$.get(this.dlg[this.level]+ntdExt,'_ajax_=1&pressedButton=delete_btn&_popup_=1&_bidv_='+this.row[this.level],function(data){xmlProcess(data);firstFocus(_id);});
//    	break;
		case 4: // copy
			if (ntdLocalStorage){
				try{$('#'+this.dlg[this.level] + '_frm').ntformls("populate",this.action[this.level]);} catch(e) {}	
				try{$('#'+this.dlg[this.level] + '_div').ntformls("populate",this.action[this.level]);} catch(e) {}	
			} else {
				$.get(this.dlg[this.level]+ntdExt,'_ajax_=1&pressedButton=copy_btn&_popup_=1&_bidv_='+this.row[this.level] + '&_calledfrom_=' + this.calledfrom[this.level] + '&' + this.other[this.level],function(data){xmlProcess(data);firstFocus(_id);});
			}	
			break;
		case 5: // view
			if (ntdLocalStorage){
				try{$('#'+this.dlg[this.level] + '_frm').ntformls("populate",this.action[this.level]);} catch(e) {}		
				try{$('#'+this.dlg[this.level] + '_div').ntformls("populate",this.action[this.level]);} catch(e) {}		
			} else {
				$.get(this.dlg[this.level]+ntdExt,'_ajax_=1&pressedButton=view_btn&_popup_=1&_bidv_='+this.row[this.level] + '&_calledfrom_=' + this.calledfrom[this.level] + '&' + this.other[this.level],function(data){xmlProcess(data);firstFocus(_id);});
			}	
			break;
		case 6: //lookup
			if (ntdLocalStorage){
				//trick 'cause we don't know if the lookup is a form, or a browse.
				$(_lsid).ntbrowsels("populate");	
				break;
				
			} else {
				$.get(this.dlg[this.level]+ntdExt,'_ajax_=1&Lookup_btn=1&_refresh_=sort&_popup_=1&LookupField='+this.luf[this.level]+'&_sort_='+this.sf[this.level] + '&_title_=' + this.pmt[this.level] + '&_calledfrom_=' + this.calledfrom[this.level] + '&' + this.other[this.level] + '&'+this.luf[this.level]+'='+$('#'+ntd.getluf()).val(),function(data){xmlProcess(data);firstFocus(_id);});
			}	
			break;
//		case 7: //zoom in
//			$.get(this.dlg[this.level]+ntdExt,'_ajax_=1&_zoom_=1&_popup_=1&_date_=' + this.row[this.level],function(data){xmlProcess(data);firstFocus(_id); _this.oncomplete[lvl]();});
//			break;
		case 100: // browse
			//console.log('ntd ls browse ntdLocalStorage=' + ntdLocalStorage + '  id=' + _lsid)
			if (ntdLocalStorage){
				$(_lsid).ntbrowsels("populate");	
				break;
			}	
		case 101: // form
			if (ntdLocalStorage){
				try {$('#'+this.dlg[this.level] + '_frm').ntformls("populate",this.action[this.level]);} catch(e) {}
				try {$('#'+this.dlg[this.level] + '_div').ntformls("populate",this.action[this.level]);} catch(e) {}
				break;
			}
		default:
			if (ntdLocalStorage){// forms with no action
				try { $('#'+this.dlg[this.level] + '_div').ntformls("populate");} catch(e) {}
				try { $('#'+this.dlg[this.level] + '_frm').ntformls("populate");} catch(e) {}
				try { $('#'+this.dlg[this.level] + '_div').ntbrowsels("populate");} catch(e) {}					
			} else {
				$.get(this.dlg[this.level]+ntdExt,'_ajax_=1&_popup_=1&_bidv_='+this.row[this.level] + '&_calledfrom_=' + this.calledfrom[this.level] + '&' + this.other[this.level],function(data){xmlProcess(data);firstFocus(_id);});	
			}
		}
		if (this.autosave[this.level] != 1){
			this.open[this.level]=1;
		}
		try { $('#'+this.dlg[this.level] + '_frm').ntform('resize');} catch(e) {}
		try { $('#'+this.dlg[this.level] + '_div').ntform('resize');} catch(e) {}
	}
}
// ----
ntdialog.prototype.pop = function (dlg){
	try{
		tinyMCE.triggerSave(true,true);
	} catch (e) { //alert('tinyMCE. Save failed. ' + e.message);
	}		
	var par='';
	var rid='';
	var prid='';
	if (this.level > -1){
		if(!ntdLocalStorage){
			SetSessionValue('popup_'+this.dlg[this.level],0)
		}	
		if (ntdFrontLoaded != 1){
			if (dlg != undefined){
				$(dlg).html('');
			} else {
				$('#'+ntd.getdlg().toLowerCase()+'_div').html('');
			}
		}	
		this.open[this.level]=0;
		if (this.saved[this.level]){
			var svd = "&_refresh_=saved"
		} else if (this.deleted[this.level]){	
			var svd = "&_refresh_=saved"
		} else {
			var svd = "&_refresh_=cancelled"
		}		
		if (this.browseid[this.level]){
			if (!ntdLocalStorage){
				$(this.browseid[this.level]).ntbrowse("disable");
			}	
			rid = $(this.browseid[this.level]).ntbrowse('option','randomid');
			prid = '&_parentrid_=' + $(this.browseid[this.level]).ntbrowse('option','parentrid');
		}	
		// moved here from ntd.close
		if (ntdLocalStorage){
			var id = this.dlg[this.level];	
			if (this.calledfrom[this.level] != null){
				id = this.calledfrom[this.level];
			}		
			// forms can be _frm (if there's a <form> tag) or _div (if there isn't). Won't be both though.
			try{$('#'+this.dlg[this.level] + '_frm').ntformls("close",this.action[this.level],this.browseid[this.level],this.row[this.level],id);}catch (e){}
			try{$('#'+this.dlg[this.level] + '_div').ntformls("close",this.action[this.level],this.browseid[this.level],this.row[this.level],id);}catch (e){}
		}
		// end
		this.level -= 1;
		if (this.parent[this.level+1] && this.parent[this.level+1] != ''){
			par = '&_parentProc_='+this.parent[this.level+1]
		}		
		if (this.level > -1){
			if (this.open[this.level] == 0){
				this.run();
			} else {			  
				if(ntdLocalStorage){
					try{$('#'+this.dlg[this.level] + '_frm').ntformls("gotFocusBack",this.action[this.level+1],this.browseid[this.level+1],this.row[this.level+1],id);}catch (e){}
					try{$('#'+this.dlg[this.level] + '_div').ntformls("gotFocusBack",this.action[this.level+1],this.browseid[this.level+1],this.row[this.level+1],id);}catch (e){}			
				} else {
					if(this.action[this.level+1]==1 || this.action[this.level+1]==4){
						// on insert/copy don't send the bidv. Rather leave the session id alone, so it'll locate on the new record 12.40
						$.get(this.dlg[this.level]+ntdExt,'_ajax_=1&_event_=gainfocus&_popup_=1&viewstate='+this.viewstate[this.level+1]+'&_equate_='+this.equate[this.level+1]+'&_action_=' + this.action[this.level+1]+'&_from_='+ this.dlg[this.level+1]+'&_calledfrom_=' + this.calledfrom[this.level+1] + svd + '&' + this.other[this.level+1] + par + '&_rid_=' + rid + prid,function(data){xmlProcess(data);});
					} else {
						$.get(this.dlg[this.level]+ntdExt,'_ajax_=1&_event_=gainfocus&_popup_=1&_bidv_=' + this.row[this.level+1]+'&viewstate='+this.viewstate[this.level+1]+'&_equate_='+this.equate[this.level+1]+'&_action_=' + this.action[this.level+1]+'&_from_='+ this.dlg[this.level+1]+'&_calledfrom_=' + this.calledfrom[this.level+1] + svd + '&' + this.other[this.level+1] + par + '&_rid_=' + rid + prid,function(data){xmlProcess(data);});
					}
				}	
			} 
		} else if (this.calledfrom[0]){
				if(ntdLocalStorage){
					try{$('#'+this.calledfrom[0] + '_frm').ntformls("gotFocusBack",this.action[this.level+1],this.browseid[this.level+1],this.row[this.level+1],id);}catch (e){}
					try{$('#'+this.calledfrom[0] + '_div').ntformls("gotFocusBack",this.action[this.level+1],this.browseid[this.level+1],this.row[this.level+1],id);}catch (e){}				
				} else {
					// on insert/copy don't send the bidv. Rather leave the session id alone, so it'll locate on the new record 12.60
					if(this.action[this.level+1]==1 || this.action[this.level+1]==4){
						$.get(this.calledfrom[0]+ntdExt,'_ajax_=1&_event_=gainfocus&_popup_=0&viewstate='+this.viewstate[this.level+1]+'&_equate_='+this.equate[this.level+1]+'&_action_=' + this.action[this.level+1]+'&_from_='+ this.dlg[this.level+1]+'&_calledfrom_=' + this.calledfrom[this.level+1] + svd + '&' + this.other[this.level+1] + par + '&_rid_=' + rid + prid,function(data){xmlProcess(data);});
					} else {
						$.get(this.calledfrom[0]+ntdExt,'_ajax_=1&_event_=gainfocus&_popup_=0&_bidv_=' + this.row[this.level+1]+'&viewstate='+this.viewstate[this.level+1]+'&_equate_='+this.equate[this.level+1]+'&_action_=' + this.action[this.level+1]+'&_from_='+ this.dlg[this.level+1]+'&_calledfrom_=' + this.calledfrom[this.level+1] + svd + '&' + this.other[this.level+1] + par + '&_rid_=' + rid + prid,function(data){xmlProcess(data);});
					}
				}
		}
	}
}
// ----
ntdialog.prototype.getluf = function (){
  if (this.level > -1){
    return this.luf[this.level];
  } else {
    return '';
  }
}
// ----
ntdialog.prototype.getdlg = function (){
  if (this.level > -1){
    return this.dlg[this.level];
  } else {
    return '';
  }
}
// ----
ntdialog.prototype.close = function (){
	//console.log('closing')
	$('#popup_'+ntd.getdlg().toLowerCase()+'_div').dialog('close'); // close does a ntd.pop
}
// ----
ntdialog.prototype.cancel = function (){
	var id = this.dlg[this.level];
	if (this.calledfrom[this.level] != null){
		id = this.calledfrom[this.level];
	}
	if (ntdLocalStorage){
		this.close()
	} else {
		var options = { 
			url: id,
			dataType: 'xml',
			success:    function(data) { 
				xmlProcess(data); 
			},
			url: this.dlg[this.level] + '_xxx_cancelled' + ntdExt,
			action: 'cancel',
			data: {	pressedButton: 'cancel_btn', _popup_: 1,_ajax_: 1, _grandparent_: this.grandparent[this.level]}
		}; 
		try{$("#"+this.dlg[this.level]+"_frm").ajaxSubmit(options);} catch(e) {}
		try{$("#"+this.dlg[this.level]+"_div").ajaxSubmit(options);} catch(e) {}
	}	
}
// ----
ntdialog.prototype.save = function (event){
	//console.log('ntd.save level=' + this.level + ' row=' + this.row[this.level])
	this.saved[this.level] = 1;
	// save TinyMCE fields
	try{
		tinyMCE.triggerSave(true,true);		      
		$('.nt-tinymce').each(function(index){      
				try{				  
					tinyMCE.execCommand('mceRemoveControl',true,$(this).attr('id'));
				} catch (e) { 
				}						
			});	
	} catch (e) {}
	// continue
	var id = this.dlg[this.level];	
	if (this.calledfrom[this.level] != null){
		id = this.calledfrom[this.level];
	}
	if (ntdLocalStorage){
		if (this.action[this.level] == 1) {
			this.row[this.level] = '';
		} 
		// forms can be _frm (if there's a <form> tag) or _div (if there isn't). Won't be both though.

		try{$('#'+this.dlg[this.level] + '_frm').ntformls("save",this.action[this.level],this.browseid[this.level],this.row[this.level],id);} catch (e){} 
		try{$('#'+this.dlg[this.level] + '_div').ntformls("save",this.action[this.level],this.browseid[this.level],this.row[this.level],id);} catch (e){}
		this.close()
	} else {
		var form = $("#"+this.dlg[this.level]+"_frm")[0];
		var formdata = new FormData(form);  
		formdata.append('pressedButton','save_btn')
		formdata.append('_popup_',1)
		formdata.append('_ajax_',1)
		formdata.append('_grandparent_',this.grandparent[this.level])
		formdata.append('_buttontext_',$(event.target).text())
		$.ajax({
           type: "POST",
		   processData: false,
           contentType: false,
           url: this.dlg[this.level] + '_xxx_validate' + ntdExt,
           data: formdata, 
           success: function(data){xmlProcess(data);}
         });

//		28 may 2020. The code below uses the jquery.form.js extension. Seems to be broken in Chrome 83. https://github.com/jquery-form/form
		// var options = {
			// url: id,
			// dataType: 'xml',
			// success:    function(data) { 
				// xmlProcess(data); 
			// },
			// url: this.dlg[this.level] + '_xxx_validate' + ntdExt,
			// data: {	pressedButton: 'save_btn', _popup_: 1,_ajax_: 1, _grandparent_: this.grandparent[this.level], _buttontext_: $(event.target).text()}
		// }; 
		// $("#"+this.dlg[this.level]+"_frm").ajaxSubmit(options);
		// use the line below instead when debugging, as it's visible in firebug.
		//$.post(id+ntdExt,'pressedButton=save_btn&_popup_=1&'+ $("#"+this.dlg[this.level]+"_frm").serialize(),function(data){xmlProcess(data);});
	}	
}
// ----
ntdialog.prototype.deleteb = function (id,br,ff,par){
	$.post(br+ntdExt,'pressedButton=deleteb_btn&_popup_=1&_fromForm_='+ ff + '&_bidv_=' + id + '&_ajax_=1&_parentProc_' + par,function(data){xmlProcess(data);});
}
// ----
ntdialog.prototype.deletef = function (){
	this.deleted[this.level] = 1;
	var id = this.dlg[this.level];
	if (this.calledfrom[this.level] != null){
		id = this.calledfrom[this.level];//.id;
	}
	$.post(this.dlg[this.level] + '_xxx_delete' + ntdExt,'pressedButton=deletef_btn&_popup_=1&_ajax_=1&'+ $("#"+this.dlg[this.level]+"_frm").serialize(),function(data){xmlProcess(data);});
	this.action[this.level] = 3; // delete
	$('#popup_'+ntd.getdlg().toLowerCase()+'_div').dialog('close'); // close does a ntd.pop
}
// ----
// jQuery UI changed _title method to not allow HTML. This override reverts it so HTML in the Dialog title is allowed.
$.widget("ui.dialog", $.extend({}, $.ui.dialog.prototype, {
    _title: function(title) {
        if (!this.options.title ) {
            title.html("&#160;");
        } else {
            title.html(this.options.title);
        }
    }
}));
// ----
var ntd = new ntdialog();
var ntdExt = '';
var ntdFrontLoaded=0;
var ntdLocalStorage=0;