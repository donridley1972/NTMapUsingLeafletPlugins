///////////////////////////////////////////////////////
//
//   jQuery Plugin for NetTalk - List
//   Part of NetTalk by CapeSoft
//   (c) 2022
//
///////////////////////////////////////////////////////

(function( $, undefined ) {

$.widget( "ui.ntjsonlist", {
        options: {
			id: '',
			procedure: '',
			hideText: 1,
			divId: '',
			allowInsert:1,
			allowDelete:1,
			allowMove:1,
			grid: [], //{"column":0,"name":"NUMBER","header":"Module Number","editType":"number"},{"column":1,"name":"NAME","header":"Module Name"},{"column":2,"name":"ACTIVE","header":"Active","editType":"checkbox", "trueValue":"yes", "falseValue":"no"}],
			json: [],
			tableClass: " nt-browse-grid nt-browse-table ui-widget-content ui-corner-all",
			headerRowClass: " nt-browse-grid-row nt-browse-row-header browsesecwinproducts-row-header" ,
			headerCellClass: " nt-browse-grid-cell nt-browse-header-all nt-browse-header-not-selected ui-corner-top nt-browse-grid-cell",
			bodyClass: " nt-browse-body nt-browse-grid-body",
			dataRowClass: "nt-browse-grid-row first-row nt-browse-row-data browsesecwinproducts-row-data nt-browse-first-line nt-browse-not-selected",
			dataCellClass: " nt-browse-grid-cell  nt-flexwidth-1",
			inputStringClass: "nt-width-100",
			inputNumberClass: "nt-width-100",
			buttonClass: "nt-flex nt-button ui-button ui-corner-all ui-widget",
			smallButtonClass: "nt-small-button",
			insertButtonClass: "", // "nt-insert-button",
			deleteButtonClass: "", //"nt-deleteb-button",
			moveupButtonClass: "", //"nt-moveup-button",
			movedownButtonClass: "", //"nt-movedown-button",
			insertTip: "", //"Click here to add a new row",
			deleteTip: "", //"Click here to remove the row",
			moveupTip: "", //"Click here to move the row up",
			movedownTip: "", //"Click here to move the row down",
			insertIcon: "", //"ui-icon-plus",
			deleteIcon: "", //"ui-icon-trash",
			moveupIcon: "", //"ui-icon-triangle-1-n",
			movedownIcon: "", //"ui-icon-triangle-1-s",
			insertText: "" //"Insert"
			
		},
		//------------------------------------------------------
        _create: function() {
			this.options.json = new Array();
        },
		//------------------------------------------------------		
        _init: function() {
			this.options.divId = this.options.id + '_div';
			if (this.options.hideText){
				$('#' + this.options.id).hide()
			}	
			//console.log('html=' + ($('#' + this.options.id).html()))
			try{ // html may be blank
				this.options.json = JSON.parse($('#' + this.options.id).html())
			} catch {}	
			$('#' + this.options.id).after('<div id="' + this.options.divId + '"></div>')
			this.build()
        },
		//------------------------------------------------------
        startTable: function() {
			return('<div class="' + this.options.tableClass + '">')
        },
		//------------------------------------------------------
        startHeaderRow: function() {
			return('<div class="' + this.options.headerRowClass + '">')	
        },
		//------------------------------------------------------
        endHeaderRow: function() {
			return('</div>')			
        },
		//------------------------------------------------------
        startHeaderCell: function(col) {
			return('<div class="' + this.options.headerCellClass + '" style="grid-row-start:1;grid-column-start:' + col + ';">')
        },
		//------------------------------------------------------
        headerValue: function(value) {
			return(value)
        },
		//------------------------------------------------------
        endHeaderCell: function() {
			return('</div>')			
        },
		//------------------------------------------------------
        startBody: function() {
			return('')
			return('<div class="' + this.options.bodyClass + '">')
        },
		//------------------------------------------------------
        endBody: function() {
			return('')
			return('</div>')			
        },
		//------------------------------------------------------
        startDataRow: function() {
			return('<div class="' + this.options.dataRowClass + '">')
        },
		//------------------------------------------------------
        endDataRow: function() {
			return('</div>')			
        },
		//------------------------------------------------------
        startDataCell: function(row,col) {
			return('<div class="' + this.options.dataCellClass + '" style="grid-row-start:' + row + ';grid-column-start:' + col + ';">')
        },
		//------------------------------------------------------
        endDataCell: function() {
			return('</div>')			
        },
		//------------------------------------------------------
        endTable: function() {
			return('</div>')
        },
		//------------------------------------------------------
        inputString: function(row,column,value) {
			return '<input data-row="'+row+'" data-column="'+column+'" data-do="list-eip"  class="' + this.options.inputStringClass + '" type="text" value="' + value + '" />'
        },
		//------------------------------------------------------
        inputNumber: function(row,column,value) {
			return '<input data-row="'+row+'" data-column="'+column+'" data-do="list-eip" class="' + this.options.inputNumberClass + '" type="number" value="' + value + '" />'
        },
		//------------------------------------------------------
        inputCheckbox: function(row,column,value,trueValue,falseValue) {
			if (value==trueValue){
				return '<input class=" nt-flex nt-checkbox nt-naked-checkbox" data-row="'+row+'" data-column="'+column+'" data-do="list-eip"  type="checkbox" data-true="' + trueValue + '" data-false="' + falseValue + '" value="' + trueValue + '" checked="checked"/>'
			} else {
				return '<input class=" nt-flex nt-checkbox nt-naked-checkbox" data-row="'+row+'" data-column="'+column+'" data-do="list-eip"  type="checkbox" data-true="' + trueValue + '" data-false="' + falseValue + '" value="' + trueValue + '" />'
			}
        },
		//------------------------------------------------------
        insertButton: function() {
			if (!this.options.allowInsert){return ''}
			return('<button type="button" data-do="list-insert"' +
			'class="' + this.options.buttonClass + ' ' + this.options.insertButtonClass + '"' +
			'title="' + this.options.insertTip + '" >' + 
			'<span class=" ui-icon ui-button-icon ' + this.options.insertIcon + '"></span><span class="ui-button-icon-space"></span>'+ this.options.insertText+ '</button>')
        },		
		//------------------------------------------------------
        deleteRowButton: function(row) {
			if (!this.options.allowDelete){return ''}
			return('<button type="button" id="delete-list-'+row+'" data-row="'+row+'"' +
			        'class="' + this.options.buttonClass + ' ' + this.options.deleteButtonClass + '"' +
					'title="' + this.options.deleteTip + '" data-do="list-delete">' +
					'<span class=" ui-icon ui-button-icon ' + this.options.deleteIcon + '"></span>' +
					'<span class="ui-button-icon-space"></span></button>')
        },
		//------------------------------------------------------
        moveButtons: function(row) {
			if (!this.options.allowMove){return ''}
			if(row == 0){
				return '<div class="' + this.options.smallButtonClass + '"></div>' + this.moveDownButton(row)
			} else if (row == this.options.json.length - 1){
				return this.moveUpButton(row) 
			} else {
				return this.moveUpButton(row) + this.moveDownButton(row)
			}
        },
		//------------------------------------------------------
        moveUpButton: function(row) {
			return('<button type="button" data-row="'+row+'"' +
			        'class="' + this.options.buttonClass + ' ' + this.options.moveupButtonClass + '"' +
					'title="' + this.options.moveupTip + '" data-do="list-up">' +
					'<span class=" ui-icon ui-button-icon ' + this.options.moveupIcon + '"></span>' +
					'<span class="ui-button-icon-space"></span></button>')
        },
		//------------------------------------------------------
        moveDownButton: function(row) {
			return('<button type="button" data-row="'+row+'"' +
			        'class="' + this.options.buttonClass + ' ' + this.options.movedownButtonClass + '"' +
					'title="' + this.options.movedownTip + '" data-do="list-down">' +
					'<span class=" ui-icon ui-button-icon ' + this.options.movedownIcon + '"></span>' +
					'<span class="ui-button-icon-space"></span></button>')
        },
		//------------------------------------------------------
        sync: function() {
			$('#' + this.options.id).html(JSON.stringify(this.options.json))
        },
		//------------------------------------------------------		
        eip: function(elem) {
			var row = $(elem).attr('data-row')
			var col = $(elem).attr('data-column')
			var rowObj = this.options.json[$(elem).attr('data-row')]
			rowObj[$(elem).attr('data-column')] = FieldValue(elem);
			this.sync()
			return 
        },
		//------------------------------------------------------
        insert: function() {
			var l = this.options.json.length
			var node = {}
			var _this=this;
			$.each(this.options.grid,function(key,value){
				switch(value["editType"]){
				case "Number":
					node[value["name"]] = parseInt(l) + 1
					break
				case "String":
					node[value["name"]] = "..."	
					break
				case "Checkbox":
					node[value["name"]] = value["falseValue"]	
					break
				default:	
					node[value["name"]] = 0	
				}		
			})
			this.options.json[l] = node
			this.clear()
			this.build()
			this.sync()
        },
		//------------------------------------------------------
        remove: function(elem) {
			var row = $(elem).attr('data-row')
			this.options.json.splice(row,1);
			this.clear()
			this.build()
			this.sync()
        },
		//------------------------------------------------------
        moveup: function(elem) {
			var row = $(elem).attr('data-row')
			var r = this.options.json.splice(row,1);
			this.options.json.splice(row-1,0,r[0]);
			this.clear()
			this.build()
			this.sync()
        },
		//------------------------------------------------------
        movedown: function(elem) {
			var row = $(elem).attr('data-row')
			var r = this.options.json.splice(row,1);
			this.options.json.splice(parseInt(row) + 1,0,r[0]);
			this.clear()
			this.build()
			this.sync()
        },
		//------------------------------------------------------
        clear: function() {
			$('#' + this.options.divId).html('')
        },
		//------------------------------------------------------		
		buildRow: function(rowData,rowNumber,key) {
			var html='';
			var _this=this;
			var value = '';
			var colNum=0;
			html = html.concat(_this.startDataRow())
			$.each(this.options.grid,function(columnNumber,column){
				if(column.name in rowData){
					value = rowData[column.name]
				} else {
					value = ''
				}
				switch(column["editType"]){
					case "Number":
						html = html.concat(_this.startDataCell(rowNumber,columnNumber+1) + _this.inputNumber(rowNumber-2,column.name,value) + _this.endDataCell())
						break
					case "String":
						html = html.concat(_this.startDataCell(rowNumber,columnNumber+1) + _this.inputString(rowNumber-2,column.name,value) + _this.endDataCell())
						break
					case "Checkbox":
						html = html.concat(_this.startDataCell(rowNumber,columnNumber+1) + _this.inputCheckbox(rowNumber-2,column.name,value,column.trueValue,column.falseValue) + _this.endDataCell())
						break
					default:	
						html = html.concat(_this.startDataCell(rowNumber,columnNumber+1) + value + _this.endDataCell())
				}
				if (colNum < columnNumber) columnNumber = colNum;
			})
			if (_this.options.allowDelete || _this.options.allowMove){
				html = html.concat(_this.startDataCell(rowNumber,colNum) + _this.deleteRowButton(rowNumber-2) + _this.moveButtons(rowNumber-2) + _this.endDataCell())
			}	
			html = html.concat(_this.endDataRow())
			return html;
        },
		//------------------------------------------------------		
        build: function() {
			var row=0;
			var column=0;
			var _this=this;
			// start table
			var html = this.startTable(html)
			//header
			column=1;
			html = html.concat(this.startHeaderRow())
			$.each(this.options.grid,function(key,value){
					html = html.concat(_this.startHeaderCell(column) + _this.headerValue(this.header) + _this.endHeaderCell())
					column += 1
			})
			html = html.concat(this.endHeaderRow())
			// body
			html = html.concat(this.startBody())
			// data rows
			row = 2
			column = 1
			if (Array.isArray(this.options.json)){
				$.each(this.options.json,function(key,value){				
					// data cells
					if (typeof(value)=='object'){
						html = html.concat(_this.buildRow(value,row,key))
					} 
					row += 1
				})
			} else { // handles the case of the json containing a single group, not a list
				if (typeof(this.options.json)=='object'){
					html = html.concat(_this.buildRow(this.options.json,row))
					row += 1
				}	
			}
			html = html.concat(this.endBody())			
			// end table
			html = html.concat(this.endTable())
			if (this.options.allowInsert){
				html = html.concat(_this.insertButton())
			}	
			$('#' + this.options.divId).html(html)
			$('#' + this.options.divId).find('[data-do="list-eip"]').off('change.jl').on('change.jl',function(e){_this.eip(this);});
			$('#' + this.options.divId).find('[data-do="list-insert"]').off('click.jl').on('click.jl',function(e){_this.insert();});
			$('#' + this.options.divId).find('[data-do="list-delete"]').off('click.jl').on('click.jl',function(e){_this.remove(this);});
			$('#' + this.options.divId).find('[data-do="list-up"]').off('click.jl').on('click.jl',function(e){_this.moveup(this);});
			$('#' + this.options.divId).find('[data-do="list-down"]').off('click.jl').on('click.jl',function(e){_this.movedown(this);});
		}
//------------------------------------------------------
});

$.extend( $.ui.ntjsonlist, {
        version: "@VERSION"
});

})( jQuery );

