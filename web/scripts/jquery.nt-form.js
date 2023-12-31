var ntLookupKey = 113;
var mobilemode = false;

(function( $, undefined ) {

// var equates and global variables here/

var tAccordion = 1;
var tTab       = 2;
var tPlain     = 3;
var tRound     = 4;
var tTabXP     = 5;
var tNone      = 6;
var tWizard    = 7;
var tCarousel  = 8;
var tTaskPanel = 9;
$.widget("ui.ntform", {
   // default options
        options: {
			defaultButton: '',
			tabType: 0,
			popup:0,
			parent:'',
			procedure: '',
			action: '',
			actionCancel: '',
			actionTarget: '',
			addSec: '',
			confirmDelete:0,
			confirmDeleteMessage:'Are you sure you want to delete this record?',
			yesDeleteText:'Yes, Delete',
			noDeleteText:'No',
			confirmCancel: 0,
			confirmCancelMessage:'Are you sure you want to cancel?',
			yesCancelText:'Yes, Cancel',
			noCancelText:'No',
			confirmText:'Confirm',
			actionCancelTarget: '' ,
			urlExt:'',
			focus: 1,
			dirty:0,
			localStorage:0
		},
		state: {
			lastChangeValue:'',
			disableSave:{},
			disableCancel:{},
			disableClose:{}
		},	
		//------------------------------------------------------
		_create: function() {
			this.start()
			if (this.options.urlExt==''){try{this.options.urlExt=ntdExt} catch(e){};}			
			this.ready();
			if (this.options.focus){
				this.firstFocus();
			}
		},	
		//------------------------------------------------------
		start: function() {
			this.state.lastChangeValue=''
			this.state.disableSave={}
			this.state.disableCancel={}
			this.state.disableClose={}
		},
		//------------------------------------------------------
		ready: function() {
			var _this=this;
			if (this.options.popup==1){
				try{
					if ($("#popup_" + this.options.procedure + "_div").dialog("option","title")==''){
						$("#popup_" + this.options.procedure + "_div").dialog("option","title",this.options.title);
					}	
				} catch (e) {};	
			}	
			this._bindEvents(this);
		},
		//------------------------------------------------------
		resize: function(){
			$('[data-widget="ntmap"]').ntmap('resize');
			if (this.options.localStorage){
				$('#'+this.options.id).ntformls("resize");
			}
		},
		//------------------------------------------------------
		_bindEvents: function(){
			var _this = this;
			$(this.element).find('input').not('.nt-locator')
				.off('keypress.ntform').on('keypress.ntform',function(e){return _this._onKeyPress(this,e);})
				.off('keydown.ntform').on('keydown.ntform',function(e){return _this._onKeyDown(this,e);})
				.off('focus.ntform').on('focus.ntform',function(e){return _this.focus(this);})
				.off('blur.ntform').on('blur.ntform',function(e){return _this.blur(this);})
				.off('valuechanged.ntform').on('valuechanged.ntform',function(e){return _this.valueChanged(this,false,e);});

			$(this.element).find('[data-nt-lof="true"]')
				.off('click.ntform').on('click.ntform',function(e){return _this.clickLookup(this);})
			$(this.element).find('[data-nt-autotab="1"]')			
				.off('keyup.ntform').on('keyup.ntform',function(e){return _this.autoTab(this,e);})
			$(this.element).find('textarea').not('.nt-locator').off('blur.ntform').on('blur.ntform',function(e){return _this.blur(this);});
			
			$(this.element).find('[data-formproc="'+_this.options.procedure+'"]').each(function(i,elem){
					switch($(elem).attr('data-do')){
					case 'imm':
						$(elem).off('change.ntform').on('change.ntform',function(e){return _this.changeField(this,e);});
						$(elem).off('sendchange.ntform').on('sendchange.ntform',function(e){return _this.sendChange(this,true,e);});
						break;
					case 'imb': // blur, not change, 'cause month et al send change on each keystroke
						$(elem).off('blur.ntform').on('blur.ntform',function(e){return _this.changeField(this,e);});
						$(elem).off('sendchange.ntform').on('sendchange.ntform',function(e){return _this.sendChange(this,true,e);});
						break;
					case 'ivs':	// immediate key press
						$(elem).off('input.ntform').on('input.ntform',function(e){return _this.changeField(this,e);})						
						break;
					case 'onclick':	
						$(elem).off('click.ntform').on('click.ntform',function(e){return _this.changeField(this,e);});
						break;
					case 'server':
						$(elem).off('click.ntform').on('click.ntform',function(e){return _this.pressButton(this);});
						break;
					}
			});
			$(this.element).find('[data-do="save"]').off('click.ntform').on('click.ntform',function(e){return _this.saveButton(this,e);});
			$(this.element).find('[data-do="close"]').off('click.ntform').on('click.ntform',function(e){return _this.closeButton(this,e);});
			$(this.element).find('[data-do="deletef"]').off('click.ntform').on('click.ntform',function(e){return _this.deleteButton(this,e);});
			$(this.element).find('[data-do="cancel"]').off('click.ntform').on('click.ntform',function(e){return _this.cancelButton(this,e);});
			$(this.element).find('[data-do="swa"]')
					.addClass('nt-right ui-state-default ui-corner-all ui-button')
					.hover(function(){
						$(this).addClass('ui-state-hover');
					}, function(){
						$(this).removeClass('ui-state-hover');
					})
					.off('click.ntform').on('click.ntform',function(e){return _this.callSecwin(this,e);});
		},
		//------------------------------------------------------
		_onKeyPress: function(elem,e) {
			switch (e.which) {
				case 13:{ // enter
					if (e.isDefaultPrevented()){
						return false;
					}	
					return(this._onEnter(elem,e));
				}
				case 9:{ // tab
					if (e.isDefaultPrevented()){
						return false;
					}	
					return(this._onTab(elem,e));									
				}
			}
		},
//------------------------------------------------------
		autoTab: function(elem,e) {
			if ($(elem).val().length == $(elem).attr("maxlength")){
				if((e.which >= 32) && (e.which <= 122)){
					jQuery(':focus').focusNextInputField();
				}
			}
		},
//------------------------------------------------------
		clickLookup: function(elem,e) {
			$("#"+elem.id).next(':button').each(
				function(i,v){
					$(this).click();
					return false;
				}
			)
		},
//------------------------------------------------------
		_onKeyDown: function(elem,e) {
			if ((e.which == 191) && (e.shiftKey == true)){
				e.which = ntLookupKey;
			}
			switch (e.which) {
				case 8:{ // explicity handle backspace on readonly fields for benefit of IE.
					if ($(elem).attr('readonly') == 'readonly'){
						return false;
					}
					break;
				}
				//case 191:  // ?
				case ntLookupKey: {// F2 by default
					$("#"+elem.id+".hasDatepicker").each(
						function(i,v){
							e.preventDefault();
							$(elem).datepicker("show");
							return false;
						}
					);
					$("#"+elem.id).next(':button').each(
						function(i,v){
							$(this).click();
							return false;
						}
					)
				}
			}
			return true;
		},
		//------------------------------------------------------
		_onEnter: function(elem,e) {
			var _this = this;
			$(this.element).find('[data-nt-default="1"]').each(function(){
				$(this).click();
				e.preventDefault();
				return false;
			})
			this.nextFocus(elem);
			return true;
		},
		//------------------------------------------------------
		_onTab: function(elem,e) {
			this.nextFocus(elem);
			return true;
		},
		//------------------------------------------------------
		gotoTab: function(index){
			switch (this.options.tabType){
			case tNone:
				break;
			case tPlain:
			case tRound:
				$([document.documentElement, document.body]).animate({
					scrollTop: $('#tab_' + this.options.procedure + index + '_div').offset().top
				}, 500);
				break;
			case tWizard:
				$('#tab_' + this.options.procedure + '_div').ntwiz("option", "active", index);	
				break;
			case tTaskPanel:
				$([document.documentElement, document.body]).animate({
					scrollTop: $('#tab_' + this.options.procedure + index + '_taskpanel_div').offset().top
				}, 500);
				$('#tab_' + this.options.procedure + index + '_taskpanel_div').accordion("option", "active", 0);
				break;
			case tAccordion:
				$('#tab_' + this.options.procedure + '_div').accordion("option", "active", index);
				break;
			case tCarousel:
				$('#tab_' + this.options.procedure + '_div').slick("slickGoTo", index);
				break;
			case tTab:	
				$('#tab_' + this.options.procedure + '_div').tabs("option", "active", index);			
				break;
			}
		},
		//------------------------------------------------------
		setTabHeadingIcon: function(index,icon){
			const regex1 = /ui-icon-(.*)/; // to get the name of the existing ui-icon
			switch (this.options.tabType){
			case tNone:
				break;
			case tPlain:
				var c = $('#tab_' + this.options.procedure + index + '_div > fieldset > legend').find('span').eq(0).attr('class').match(regex1)[1]
				$('#tab_' + this.options.procedure + index + '_div > fieldset > legend').find('span').eq(0).removeClass('ui-icon-' + c).addClass('ui-icon-' + icon)
				break;
			case tRound:
				var c = $('#tab_' + this.options.procedure + index + '_div > h3').find('span').eq(0).attr('class').match(regex1)[1]
				$('#tab_' + this.options.procedure + index + '_div > h3').find('span').eq(0).removeClass('ui-icon-' + c).addClass('ui-icon-' + icon)
				break;
			case tWizard:
				$('#tab_' + this.options.procedure + '_div').ntwiz("setTabHeadingIcon",index,icon);
				break;
			case tAccordion:
				var c = $('#tab_' + this.options.procedure + '_div > h3').eq(index).find('div > span').eq(0).attr('class').match(regex1)[1]
				$('#tab_' + this.options.procedure + '_div > h3').eq(index).find('div > span').eq(0).removeClass('ui-icon-' + c).addClass('ui-icon-' + icon)
				break;
			case tCarousel:
				break;
			case tTaskPanel:
				var c = $('#tab_' + this.options.procedure + index + '_taskpanel_div > h3 > div').find('span').eq(0).attr('class').match(regex1)[1]
				$('#tab_' + this.options.procedure + index + '_taskpanel_div > h3 > div').find('span').eq(0).removeClass('ui-icon-' + c).addClass('ui-icon-' + icon)
				break;
			case tTab:		
				var c = $('#tab_' + this.options.procedure + '_div > ul').find('li').eq(index).find('span').eq(0).attr('class').match(regex1)[1]
				$('#tab_' + this.options.procedure + '_div > ul').find('li').eq(index).find('span').eq(0).removeClass('ui-icon-' + c).addClass('ui-icon-' + icon)
				break;
			}		
		},
		//------------------------------------------------------
		setTabHeadingText: function(index,heading){
			switch (this.options.tabType){
			case tNone:
				break;
			case tPlain:
				$('#tab_' + this.options.procedure + index + '_div > fieldset > legend > div').text(heading);
				break;
			case tRound:
				$('#tab_' + this.options.procedure + index + '_div > h3 > div').text(heading);
				break;
			case tWizard:
				$('#tab_' + this.options.procedure + '_div').ntwiz("setTabHeadingText",index,heading);
				break;
			case tAccordion:
				$('#tab_' + this.options.procedure + '_div > h3').eq(index).find('div > div').text(heading);		
				break;
			case tCarousel:
				$('#tab_' + this.options.procedure + index + '_div > h3 > div').text(heading);
				break;
			case tTaskPanel:
				$('#tab_' + this.options.procedure + index + '_taskpanel_div > h3 > div > div').text(heading);		
				break;
			case tTab:		
				$('#tab_' + this.options.procedure + '_div > ul').find('li').eq(index).find('div').text(heading);		
				break;				
			}
		},
		//------------------------------------------------------
		hideTab: function(index){
			var id='';
			switch (this.options.tabType){
			case tNone:
			case tPlain:
			case tRound:
				$('#tab_' + this.options.procedure + index + '_div').hide();
				break;
			case tWizard:
				$('#tab_' + this.options.procedure + '_div').ntwiz("option","hideTab",index);
				break;
			case tAccordion:
				$('#tab_' + this.options.procedure + '_div').find('h3').eq(index).hide();
				$('#tab_' + this.options.procedure + '_div').find('h3').eq(index).next().hide();
				break;
			case tCarousel:
				// not supported
				break;
			case tTaskPanel:
				$('#tab_' + this.options.procedure + index + '_taskpanel_div').hide();
				break;
			case tTab:
				$('#tab_' + this.options.procedure + '_div > ul').find('li').eq(index).hide();
				break;
			}
		},
		//------------------------------------------------------
		showTab: function(index){
			var id='';
			switch (this.options.tabType){
			case tNone:
			case tPlain:
			case tRound:
				$('#tab_' + this.options.procedure + index + '_div').show();
				break;
			case tWizard:
				$('#tab_' + this.options.procedure + '_div').ntwiz("option","unhideTab",index);
				break;
			case tAccordion:
				$('#tab_' + this.options.procedure + '_div').find('h3').eq(index).show();
				if ($('#tab_' + this.options.procedure + '_div').accordion('option','active') == index){
					$('#tab_' + this.options.procedure + '_div').find('h3').eq(index).next().show();
				}
				break;
			case tCarousel:
				// not supported
				break;
			case tTaskPanel:
				$('#tab_' + this.options.procedure + index + '_taskpanel_div').show();
				break;				
			case tTab:
				$('#tab_' + this.options.procedure + '_div > ul').find('li').eq(index).show();
				break;
			}
		},
		//------------------------------------------------------
		firstFocus: function(){
			var e;
			var t = 4000000000;
			$(this.element).find(' :input').not('[readonly],[disabled],[type="hidden"]').each(function(){
				tx = $(this).offset().top;
				if (tx < t && tx != 0){
					e = this;
					t = tx;
				}
			})
			$(e).focus();
		},

		//------------------------------------------------------
		_calcURL : function(elem){
			var url = $(elem).attr('id');
			if (!url){
				url = $(elem).attr('name');
			} else {
				if ($(elem).attr('type') == 'radio'){
					url = url.slice(0,url.lastIndexOf('_'));
				}
			}
			var f = $(elem).attr('data-formproc');
			if (!f){
				f = this.options.procedure;
			}
			return f +'_' + url + '_value';
		},

		//------------------------------------------------------
		focus : function(elem,e,i){			
			switch (elem.type){
			case 'text':
			case 'number':
			case 'email':
			case 'url':
			case 'range':
				if ($(elem).attr("data-noFocus") == "true"){
					$(elem).attr("data-noFocus","false");
				} else {	
					try{ $('#osk').ntosk('getFocus',elem);} catch(e) {};	
				}	
				try{$('#osk').ntosk('show');} catch(e) {};	
			}
			try{$('#osk').ntosk('mdstatus',0)} catch(e){};	
		},
		//------------------------------------------------------
		blur: function(elem) {
			try{
				$('#osk').ntosk('startHide');	
				if ($('#osk').ntosk('mdstatus')==0){
					this.sendChange(elem,false);					
				}
				$('#osk').ntosk('mdstatus',0)
			} catch(e) {};	
			return this;
		},
		
		//------------------------------------------------------
		valueChanged : function(elem,focus){			
			var _this=this;
			if ($(elem).attr('data-do') == 'ivs'){
				_this.sendChange(elem,focus);
			}
			try {
				$(elem).autocomplete("search");
			} catch(e) {};
			return this;
		},
		//------------------------------------------------------
		sendChange : function(elem,focus){
			if ( this.getValue(elem) != this.state.lastChangeValue){
				this.changeField(elem);				
			}
			try{ $('#osk').ntosk('startHide'); } catch(e) {};	
			if (focus){
				this.nextFocus(elem);
			}	
		},
		//------------------------------------------------------
		changeField : function(elem){
			var _this=this;
			var formstate=$(elem).closest('form').find('[name="FormState"]').val();
			if ($(elem).attr("data-ac") == "open"){ // dont do anything if auto-complete is open
				return this;
			}
			if ($(elem).attr("data-wait") == "true"){ // dont do anything on-screen-keyboard was clicked.
				return this;
			}
					// in most cases want to send the id first, not the name. The id is unique to the field on
					// the form, hence has a unique validate:: routine. For radios we have to tweak the id to remove
					// the unique suffix.
			var url = this._calcURL(elem);
			this.state.lastChangeValue = this.getValue(elem);
			if (this.options.localStorage){ // got value
				$('#'+this.options.id).ntformls("onChangeField",elem);
			} else {
				$.post(url+this.options.urlExt,
					'_popup_='+this.options.popup+'&_event_=accepted&value='+this.state.lastChangeValue+'&_ajax_=1&_rnd_='+Math.random()+'&formstate=' + formstate+'&_parentProc_=' + this.options.parent,
					function(data){_this._onAjaxComplete(data);});
			}		
			this.options.dirty = true;
			return this;
		},

		//------------------------------------------------------
		getValue: function(elem){
			  // moved outside the widget so it can be used by ntformls
			var ans ='';
			ans = getFormFieldValue(elem);
			// if called as a post, do not encode & and %. If called from EIP then do.
			ans = encodeURI(ans);
			ans = ans.replace(/&/g,"%26");
			ans = ans.replace(/#/g,"%23");
			ans = ans.replace(/\+/g,"%2B");
			ans = ans.replace(/%0D%0A/g,"%0A");
			ans = ans.replace(/%0D/g,"%0A");
			ans = ans.replace(/%0A/g,"%0D%0A");			
			return ans;
		},
		//------------------------------------------------------
		hideMessage: function() {
			var fn = '#'+this.options.procedure;
			fn = fn.toLowerCase();
			$(fn + '_alert_div').addClass('nt-hidden');
			return this;
		},
		//------------------------------------------------------
		showMessage: function(message) {
			var fn = '#'+this.options.procedure;
			fn = fn.toLowerCase();
			$(fn + '_alert_div').empty().append(message).removeClass('nt-hidden');
			return this;
		},		
		//------------------------------------------------------
		hideField: function(fieldname) {
			var fn = '#'+this.options.procedure + '_' + fieldname;
			fn = fn.toLowerCase();
			$(fn + '_prompt_div').addClass('nt-hidden');			
			$(fn + '_value_div').addClass('nt-hidden');
			$(fn + '_comment_div').addClass('nt-hidden');
			return this;
		},
		//------------------------------------------------------
		showField: function(fieldname) {
			var fn = '#'+this.options.procedure + '_' + fieldname;
			fn = fn.toLowerCase();
			$(fn + '_prompt_div').removeClass('nt-hidden');
			$(fn + '_value_div').removeClass('nt-hidden');
			$(fn + '_comment_div').removeClass('nt-hidden');
			return this;
		},
		//------------------------------------------------------
		disableClose: function(context) {
			if (context){
				this.state.disableClose[context] = 1;
			}
			id = $(this.element).find('[data-do="close"]').attr("id");
			try{$('#'+id).prop("disabled",true).button( "refresh" );} catch (e) {};
			return this;
		},
		//------------------------------------------------------
		disableSave: function(context) {
			if (context){
				this.state.disableSave[context] = 1;
			}
			id = $(this.element).find('[data-do="save"]').attr("id");
			try{$('#'+id).prop("disabled",true).button( "refresh" );} catch (e) {};
			return this;
		},
		//------------------------------------------------------
		disableCancel: function(context) {
			if (context){
				this.state.disableCancel[context] = 1;
			}
			id = $(this.element).find('[data-do="cancel"]').attr("id");
			try{$('#'+id).prop("disabled",true).button( "refresh" );} catch (e) {};
			return this;
		},
		//------------------------------------------------------
		enableClose: function(context) {
			var all=0;
			if (context){
				this.state.disableClose[context] = 0;			
				$.each(this.state.disableClose, function( key, value ){
					all += value;
				});
			}	
			if (all == 0){
				id = $(this.element).find('[data-do="close"]').attr("id");
				try{$('#'+id).prop("disabled",false).button( "refresh" );} catch (e) {};
			}	
			return this;
		},
		//------------------------------------------------------
		enableSave: function(context) {
			var all=0;
			if (context){
				this.state.disableSave[context] = 0;			
				$.each(this.state.disableSave, function( key, value ){
					all += value;
				});
			}	
			if (all == 0){
				id = $(this.element).find('[data-do="save"]').attr("id");
				try{$('#'+id).prop("disabled",false).button( "refresh" );} catch (e) {};
			}	
			return this;
		},
		//------------------------------------------------------
		enableCancel: function(context) {
			var all=0;
			if (context){
				this.state.disableCancel[context] = 0;			
				$.each(this.state.disableCancel, function( key, value ){
					all += value;
				});
			}	
			if (all == 0){
				id = $(this.element).find('[data-do="cancel"]').attr("id");
				try{$('#'+id).prop("disabled",false).button( "refresh" );} catch (e) {};
			}	
			return this;
		},
		//------------------------------------------------------
		show: function() {
			$('#' + this.options.procedure + '_div').show();
			return this;
		},
		//------------------------------------------------------
		hide: function() {
			$('#' + this.options.procedure + '_div').hide();
			return this;
		},
		//------------------------------------------------------
		onOpen: function() {
			this.hide();
		},
        //------------------------------------------------------
		_onAjaxComplete: function(data) {
			xmlProcess(data);
			this.ready();
			return this;
		},

		//------------------------------------------------------
		setTimer : function(fld,t) {
			if (this.options.localStorage){
			} else {
				setTimeout("$('#"+$(this.element).attr('id')+"').ntform('server','"+this.options.procedure + '_' + fld + '_value'+"','_event_=timer');",t);
			}	
			return this;
		},
        //------------------------------------------------------
		nextFocus : function(elem) {
			var nf = $(elem).attr('data-nextfocus');
			if (nf){
				$('#'+nf).focus();
			} else {
				var fields = $(elem).parents('form:eq(0),body').find('button,input,textarea,select').not(':hidden');
				var index = fields.index(elem);
				if ( index > -1 && ( index + 1 ) < fields.length ) {
					fields.eq(index + 1).focus();
				} else {
					fields.first().focus();
				}
			}
			return this;
		},

		//------------------------------------------------------
		// want to do an ajax call from the form, but with all the form fields included.
        pressButton : function(elem){
			var _this=this;
			var urlA= this.options.procedure+'_' + $(elem).attr('name') + '_value' + ntdExt;
			try{$(elem).attr("disabled","disabled").button( "refresh" );} catch (e) {};
			this.removePlaceHolder();
			// save TinyMCE fields
			try{
				tinyMCE.triggerSave(true,true);
			} catch(e){};
			if(this.options.localStorage){
			} else {
				if(!$(elem).closest("form").attr('method')){
					this.server(urlA,'_event_=accepted','value='+$(elem).attr("value"))
				} else {
					//$(elem).closest("form").ajaxSubmit(options); // this line seems to fail in Chrome 83.0.4103.61, https only, form with upload file control. 
					var form = $(elem).closest("form")
					var formdata = form.serialize() + '&_event_=accepted&value=' + $(elem).attr("value") + '_ajax_=1&_parentProc_=' + this.options.parent + '&_rnd_=' + Math.random();
					$.ajax({
					   type: "POST",
					   url: urlA,
					   data: formdata, // serializes the form's elements. Does not serialize File Upload fields.
					   success: function(data){_this._onAjaxComplete(data)}
					 });
				}	
			}	
			this.nextFocus(elem);
			return this;
        },
        //------------------------------------------------------
        clickSave : function(){
			$(this.element).find('[data-do="save"]').click();		
        },
        //------------------------------------------------------
        clickClose : function(){
			$(this.element).find('[data-do="close"]').click();		
        },
        //------------------------------------------------------
        closeButton : function(elem,event){
			if (this.options.popup){
				ntd.close(event);
			} else {
				if (this.options.action){
					window.location.href = this.options.action;
				}
			}
        },
        //------------------------------------------------------
        saveButton : function(elem,event){
			$(elem).closest("form").find('.slick-cloned').remove() // work-around :: do not want to include carousel cloned elements in the post.
			// Save ACE fields
			$(this.element).find('[data-edit="aceeditor"]').each(function(i,elem){
				var id = $(elem).attr('data-field');
				var eid = window[id + "_ace"]; 
				$('#' + id).val(eid.getValue());
			})
			// Save CKEditor fields fields
			$(this.element).find('[data-edit="ckeditor4"]').each(function(i,elem){
				var id = $(elem).attr('id');
				CKEDITOR.instances[id].updateElement();				
			})			
			// continue
			if (this.options.popup){
				ntd.save(event);
			} else {
				if (this.options.action && this.options.action != ''){
					$(elem).closest("form").attr("action",this.options.action).attr("target",this.options.actionTarget);
				}
				// set all buttons disabled, if target of button is same frame.
				t = $(elem).closest("form").attr("target");
				if (t == "" || t == "_self" || t == "_top"){
					$(':button').attr('disabled', 'disabled');
				}
				$(elem).closest("form").append('<input type="hidden" name="_buttontext_" value="'+$(event.target).closest("button").val()+'" />');
				$(elem).closest("form").append('<input type="hidden" name="_refresh_" value="saved" />');
				$(elem).closest("form").append('<input type="hidden" name="pressedButton" value="save_btn" />');
				$("#_webkit_").val(Math.random());
				this.removePlaceHolder();
				$(elem).closest("form").submit();
			}
        },
        //------------------------------------------------------
        deleteButton : function(elem,event){
			var _this=this;
			if (this.options.confirmDelete) {
				//ntConfirm(this.options.confirmDeleteMessage,this.options.confirmText,this.options.yesDeleteText,this.options.noDeleteText,this.deletenow,elem,event,this);
				$('body').append('<div id="message_confirm" title="'+_this.options.confirmText+'" class="nt-flex">' + 
				'<div><div class="ui-icons-error ui-icon ui-error-icon ui-icon-alert nt-left nt-margin-right-1"></div></div>' +
				'<div>' +  this.options.confirmDeleteMessage + '</div></div>');
				$( "#message_confirm" ).dialog({
					resizable: false,
					modal: true,
					buttons: [{
						text: _this.options.yesDeleteText,
						icon: 'ui-icon-trash',
						class:'nt-deleteb-button',
						click : function() {    
							$( this ).dialog( "close" );
							$( "#message_confirm" ).remove();
							_this.deletenow(elem,event,_this);
						}
					}, {

						icon: 'ui-icon-cancel',
						text: _this.options.noDeleteText,
						click: function() {
							$( this ).dialog( "close" );
							$( "#message_confirm" ).remove();
							return _this;
						}
					}]	
				});
			} else {
				this.deletenow(elem,event,this);
			}
        },
        //------------------------------------------------------
        deletenow : function(elem,event,_this){
			if (_this.options.popup){
				ntd.deletef(event);
			} else {
				if (_this.options.action && _this.options.action != ''){
					$(elem).closest("form").attr("action",_this.options.action).attr("target",_this.options.actionTarget);
				}
				// set all buttons disabled, if target of button is same frame.
				t = $(elem).closest("form").attr("target");
				if (t == "" || t == "_self" || t == "_top"){
					$(':button').attr('disabled', 'disabled');
				}
				$(elem).closest("form").append('<input type="hidden" name="_buttontext_" value="'+$(event.target).closest("button").val()+'" />');
				$(elem).closest("form").append('<input type="hidden" name="_refresh_" value="saved" />');
				$(elem).closest("form").append('<input type="hidden" name="pressedButton" value="deletef_btn" />');
				$("#_webkit_").val(Math.random());
				_this.removePlaceHolder();
				$(elem).closest("form").submit();
			}    
        },		
        //------------------------------------------------------
		cancelButton : function(elem,event){
			if (this.options.confirmCancel && this.options.dirty) {
				ntConfirm(this.options.confirmCancelMessage,this.options.confirmText,this.options.yesCancelText,this.options.noCancelText,this.cancelNow,elem,event,this);
			} else {
				this.cancelNow(elem,event,this);
			}
        },		
        //------------------------------------------------------
		cancelNow : function(elem,event,_this){
			if (_this.options.popup){
				ntd.cancel(event);
			} else {
				if (_this.options.actionCancel && _this.options.actionCancel != ''){
				  $(elem).closest("form").attr("action",_this.options.actionCancel).attr("target",_this.options.actionCancelTarget);
				}
				// set all buttons disabled, if target of button is same frame.
				t = $(elem).closest("form").attr("target");
				if (t == "" || t == "_self" || t == "_top"){
					$(':button').attr('disabled', 'disabled');
				}
				$(elem).closest("form").append('<input type="hidden" name="_buttontext_" value="'+$(event.target).closest("button").val()+'" />')
				$(elem).closest("form").append('<input type="hidden" name="pressedButton" value="cancel_btn" />')
				$("#_webkit_").val(Math.random());
				_this.removePlaceHolder();
				$(elem).closest("form").submit();
			}
		},
        //------------------------------------------------------
        callSecwin : function(elem,event){
			ntd.push('secwinwebuseraccess','','header',1,2,null,'','','_screen_=' + this.options.addsec);
			return this;
        },

        //------------------------------------------------------
		removePlaceHolder : function (){
			$('[placeholder]').each(function(i) {
				var e = $(this);
				if (e.val() === e.attr('placeholder')){
					e.val("");
				}
			});
		},
        //------------------------------------------------------
		server : function(url) {      // send async request to server procedure
			var parms='';
			var _this=this;
			for(var d = 1; d < arguments.length; d++){
				parms += arguments[d] + '&';
			}
			if (parms==''){
				parms +=  '&'
			}
			parms +=  '_ajax_=1' + '&_parentProc_=' + this.options.parent + '&_rnd_=' + Math.random();
			if (this.options.localStorage){
			} else {
				$.get(url+this.options.urlExt,parms,function(data){_this._onAjaxComplete(data);});
			}	
			return this;
		},

		//------------------------------------------------------
		destroy: function() {
			$.Widget.prototype.destroy.apply(this, arguments); // default destroy
			// now do other stuff particular to this widget
		}
 });

$.extend( $.ui.ntform, {
        version: "@VERSION"
});

})( jQuery );
// // ---------------------------------------------------------------------------------------
// // add functionality to "slider" so it has refresh method. 
// // this refreshes the value, and slider, without issuing a change event.
// // called from nt-websockets when updating a value pushed from the server
// // ---------------------------------------------------------------------------------------
 $.widget("ui.ntslider", $.extend({}, $.ui.slider.prototype, {
	//----------------------------------------------------------------------------
	refresh: function(){
		// currently only supports a single-value slider.
		this.options.value = this._trimAlignValue( $('#' +this.options.id).val() );
		this._refreshValue()
	}
 }));
 $.ui.ntslider.defaults = $.extend({}, $.ui.slider.defaults);
 
	//----------------------------------------------------------------------------

// // ---------------------------------------------------------------------------------------
// // add functionality to "checkbox" checkboxradio so it has an "on" and "off" text, and icon option.
// // updated in NT 11 to support jQuery UI 1.12
// // ---------------------------------------------------------------------------------------
 $.widget("ui.checkboxbutton", $.extend({}, $.ui.checkboxradio.prototype, {
	//----------------------------------------------------------------------------
	_init: function(){
		var _this=this;		
		this.element.data('checkboxradio', this.element.data('checkboxbutton'));
		this._setLabelState(); 
		this._updateLabel();		
		$(this.element).on('click',function(e){ _this._clicked()});
		$(this.element).on('change',function(e){ _this.refresh()});
		var i = $.ui.checkboxradio.prototype._init.apply(this, arguments);
		return i;
	},
	//----------------------------------------------------------------------------
	refresh: function(force){
		if (force ==0){
			$(this.element).prop("checked",false);
		} else if (force ==1){
			$(this.element).prop("checked",true);
		} else if (this.element.is( ":checked" )==false){
			$(this.element).prop("checked",false);
		} else if (this.element.is( ":checked" )==true){
			$(this.element).prop("checked",true);
		}
		this._setLabelState();
		var i = $.ui.checkboxradio.prototype.refresh.apply(this, arguments);
		return i;
	 },
	//----------------------------------------------------------------------------
	_setLabelState: function(){
		if($(this.element).prop("checked")){
			this.options.label = this.options.trueText;			
		} else {
			this.options.label = this.options.falseText;
		}	
		this._removeClass( this.icon, null, "ui-state-hover")// fixes bug in jquery theme. 		
	},
	//----------------------------------------------------------------------------
	_clicked: function(){
		this._setLabelState()
		this.refresh();
	},	
	//----------------------------------------------------------------------------
	_updateIcon: function( checked ) {
		var toAdd = "ui-icon ui-icon-background ";
		if (!this.options.falseIcon){this.options.falseIcon='ui-icon-blank'}
		if (!this.options.trueIcon){this.options.trueIcon='ui-icon-blank'}
		if (this.options.icon) {
			if (!this.icon) {
				this.icon = $( "<span>" );
				this.iconSpace = $( "<span> </span>" );
				this._addClass( this.iconSpace, "ui-checkboxradio-icon-space" );
			}
			toAdd += checked ? this.options.trueIcon + " ui-state-checked" : this.options.falseIcon; 
			this._removeClass( this.icon, null, checked ? this.options.falseIcon : this.options.trueIcon ); 
			this._removeClass( this.icon, null, "ui-state-hover")
			if( !checked && this.options.falseIcon.toLowerCase() != 'blank'){
				this._removeClass( this.icon, null, "ui-icon-blank" ); // jquery adds this to false checkboxes.
			}
			this._addClass( this.icon, "ui-checkboxradio-icon", toAdd );
			if ( !checked ) {
				if(this.options.trueIcon==this.options.falseIcon){
					this._removeClass( this.icon, null, " ui-state-checked" );
				} else {
					this._removeClass( this.icon, null, this.options.trueIcon + " ui-state-checked" );
				}
			}
			this.icon.prependTo( this.label ).after( this.iconSpace );
		} else if ( this.icon !== undefined ) {
			this.icon.remove();
			this.iconSpace.remove();
			delete this.icon;
		}
	}	
 }));
 $.ui.checkboxbutton.defaults = $.extend({}, $.ui.checkboxradio.defaults);

//------------------------------------------------------
function changeAce(id){
	var eid = window[id + "_ace"]; 
	$('#' + id).val(eid.getValue());
	$('#' + id).change()
}

// Generic funtion to get the value of a form field. Can't be inside the widget because it's hard to get return values.
//------------------------------------------------------
function getFormFieldValue(elem,value){
	var ans ='';
	var typ = elem.type;
	var i = 0;
	if (typ == undefined){		
		if (elem.length){
			elem = elem[0]
			typ = elem.type;
		} else {
			return value;
		}	
		
	}
	switch (typ){
	case "radio":
		ans = $(elem).val();
		break;
	case "checkbox":
		if (elem.checked){
			ans = $(elem).attr("data-true");
			if(ans===undefined){
				ans = elem.value;
			}
		} else {
			ans = $(elem).attr("data-false");
			if(ans===undefined){
				ans = 0;
			}			
		}
		break;
	case "select-multiple":
		for(i = 0; i < elem.length; i++) {
			if(elem.options[i].selected) {
				ans = ans + ';|;' + elem.options[i].value;
			}
		}
		break;
	case "file":
		var files = elem.files;
		try {
			for (i=0;i<files.length;i++){
				ans = ans + ';|;' + files[i].name;
			}
		} catch (err){
			ans = elem.value;
		}
		break;
	case "text":
		var id = $(elem).attr('id')+'_slider';
		if ($('#'+id).attr('id')){
			var values = $('#'+id).slider("values");
			for(i=0;i < values.length;i++){
				ans = ans + values[i] + ';';
			}					
			break;
		} // deliberatly drop down to default if it's not a slider.				
	default:
		if ($(elem).data('luv')){
			ans = $(elem).data('luv');
		} else {
			ans = elem.value; // value not encoded automatically in IE when doing an Ajax Get.
		}
	}
	return ans;
}
