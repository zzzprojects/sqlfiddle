	
	ddl_builder = function (args) {

		// output settings
		this.fieldPrefix = '';
		this.fieldSuffix = '';
		
		this.dateFormatMask = "yyyy-mm-dd HH:MM:ss";
		
		this.charType = 'varchar';
		this.intType = 'int';
		this.floatType = 'numeric';
		this.dateType = 'datetime';
		
		// input settings
		this.valueSeparator = '';

		this.column_count = 0;
		this.definition = { 
				tableName: "Table1",
			    columns: [/* sample column structure
			    			{
			    				name: 'id',
			    				type: 'int',
			    				length: '',
			    				db_type: 'int4'
			    			},
			    			{
			    				name: 'name',
			    				type: 'char',
			    				length: 20,
			    				db_type: 'varchar(20)'
			    			}			    	
			     			*/],
			    data: [/* sample data structure
			    			 // r for "row", v for "value"
			    			{r:[{v:1},{v:'Jake'}]},
			    			{r:[{v:2},{v:'Rachel'}]},
			    			{r:[{v:3},{v:'Andrew'}]},
			    			{r:[{v:4},{v:'Ada'}]},
			    			{r:[{v:5},{v:'Lucy O\'Malley'}]}
			    
			    
			     		*/]
		    };

		
		this.ddlTemplate = "\
CREATE TABLE {{fieldPrefix}}{{tableName}}{{fieldSuffix}}\n\
	({{#each_with_index columns}}{{#if index}}, {{/if}}{{../fieldPrefix}}{{name}}{{../fieldSuffix}} {{db_type}}{{/each_with_index}});\n\n\
INSERT INTO {{fieldPrefix}}{{tableName}}{{fieldSuffix}}\n\
	({{#each_with_index columns}}{{#if index}}, {{/if}}{{../fieldPrefix}}{{name}}{{../fieldSuffix}}{{/each_with_index}})\n\
VALUES\n\
	{{#each_with_index data}}{{#if index}},\n\
	{{/if}}({{#each_with_index r}}{{#if index}}, {{/if}}{{formatted_field ../..}}{{/each_with_index}}){{/each_with_index}}";

		this.compiledTemplate = Handlebars.compile(this.ddlTemplate);
		this.setup(args);
		return this;
	}
	
	ddl_builder.prototype.setup = function (settings) {
		for (opt in settings)
		{
			this[opt] = settings[opt];
		}
		
		if (settings["ddlTemplate"])
			this.compiledTemplate = Handlebars.compile(this.ddlTemplate);
		
		if (settings["tableName"])
			this.definition.tableName = settings.tableName;
		
		return this;
	}
	
	ddl_builder.prototype.setupForDBType = function (type) {
		
		switch (type)
		{
			case 'SQL Server':
				this.setup({ 
								fieldPrefix: '[',
								fieldSuffix: ']', 
							});	
			break;
/*
			case 'MySQL':
				this.setup({ 
								fieldPrefix: '`',
								fieldSuffix: '`', 
							});	
			break;
*/
			case 'Oracle':	
				var template = 
"CREATE TABLE {{fieldPrefix}}{{tableName}}{{fieldSuffix}}\n\
	({{#each_with_index columns}}{{#if index}}, {{/if}}{{../fieldPrefix}}{{name}}{{../fieldSuffix}} {{db_type}}{{/each_with_index}})\n/\n\
INSERT ALL\
{{#each_with_index data}}\n\
	INTO \
{{../fieldPrefix}}{{../tableName}}{{../fieldSuffix}} \
({{#each_with_index r}}{{#if index}}, {{/if}}{{../../fieldPrefix}}{{column_name_for_index ../..}}{{../../fieldSuffix}}{{/each_with_index}})\n\
	     VALUES \
({{#each_with_index r}}{{#if index}}, {{/if}}{{formatted_field ../..}}{{/each_with_index}})\
{{/each_with_index}}\n\
SELECT * FROM dual";
												
					this.setup({ 
					
								ddlTemplate: template,
								dateType: 'timestamp',
								charType: 'varchar2'
							});	
			break;

		}
		return this;
	}
	
	ddl_builder.prototype.populateDBTypes = function () {
		for (var i=0;i<this.definition.columns.length;i++)
		{
			if (this.definition.columns[i].type == 'charType')
				this.definition.columns[i].db_type = this[this.definition.columns[i].type] + "(" + this.definition.columns[i].length + ")";
			else	
				this.definition.columns[i].db_type = this[this.definition.columns[i].type];
		}
		
		this.definition.dateFormatMask = this.dateFormatMask;
		
	};
	
	ddl_builder.prototype.populateWrappers = function () {
		this.definition.fieldPrefix = this.fieldPrefix;
		this.definition.fieldSuffix = this.fieldSuffix;
	};
	
	
	ddl_builder.prototype.guessValueSeparator = function (raw) {
		

	    var lines = raw.split("\n");
	    var header_found = false, column_count = 0, found_separator = '';
	    
	    for (var i = 0; i<lines.length; i++)
    	{
	    	if (lines[i].search(/[A-Z0-9_]/i) != -1 && !header_found) // if this line contains letters/numbers/underscores, then we can assume we've hit the header row 
	    	{
	    		var chunks = lines[i].match(/[A-Z0-9_]+([^A-Z0-9_]*)/gi);

	    		header_found = true;
	    		
	    		for (var j = 0; j < chunks.length; j++)
	    		{
	    			var this_separator = chunks[j].match(/[A-Z0-9_]+([^A-Z0-9_]*)$/i)[1];
	    			
	    			if (this_separator.search(/^\s+$/) != -1)
	    				this_separator = new RegExp("\\s+");
	    			else
	    				this_separator = $.trim(this_separator);
					console.log(found_separator instanceof RegExp);
					if (this_separator instanceof RegExp || this_separator.length)
					{
		    			if (!(found_separator instanceof RegExp) && !found_separator.length)
		    				found_separator = this_separator;
		    			else if (found_separator != this_separator)
		    				return {status: false, message: 'Unable to find consistent column separator in header row'}; // different separators founds?
	    			}
	    			else if (! (this_separator instanceof RegExp) && !(found_separator instanceof RegExp) && !found_separator.length)	
	    			{
	    				found_separator = "\n";
	    			}
	    			
	    		}
				if (found_separator instanceof RegExp || found_separator.length)
	    			column_count = lines[i].split(found_separator).length;
	    		else
	    			column_count = 1;
	    		
	    		
	    	}
	    	else if (lines[i].search(/[A-Z0-9_]/i) != -1)
    		{
	    		if (lines[i].split(found_separator).length != column_count)
	    			return {status: false, message: 'Line ' + i + ' does not have the same number of columns as the header, based on separator "' + found_separator + '".'};
    		
    		}
    	
    	}
	    return {status: true, separator: found_separator, column_count: column_count};
	}
	
	ddl_builder.prototype.parse = function (raw) {

		

		if (!this.valueSeparator.length)
		{	
			var result = this.guessValueSeparator(raw);
			if (!result.status)
				return "ERROR! " + result.message;
			else
			{
				this.column_count = result.column_count;
				this.valueSeparator = result.separator;
			}
		}
		
	    var lines = raw.split("\n");
	    
	    for (var i=0;i<lines.length;i++)
	    {
            if ($.trim(lines[i]).length && lines[i].split(this.valueSeparator).length == this.column_count)
            {
	    		
	            	var elements = $.trim(lines[i]).split(this.valueSeparator);
	            	

	            	if (! this.definition.columns.length)
	            	{	
		        	    for (var j = 0; j < elements.length; j++)
		        	    {	
		        	            var value = $.trim(elements[j]);
		        	            if (value.length)
		        	            	this.definition.columns.push({"name": value});
		        	            else
		        	            	this.definition.columns.push(false);
		        	    }
	            	}
	            	else
	            	{
	            	
			            var tmpRow = [];
			            for (var j = 0; j < elements.length; j++)
			            {
			            	if (this.definition.columns[j] !== false)
			            	{
			                    var value = $.trim(elements[j]).replace(/'/g, "''");
		
			                    // if the current field is not a number, or if we have previously decided that this one of the non-numeric field types...
			                    if (isNaN(value) || this.definition.columns[j].type == 'dateType' || this.definition.columns[j].type == 'charType')
			                    {
			                    	
			                    	// if we haven't previously decided that this is a character field, and it can be cast as a date, then declare it a date 
			                    	if (this.definition.columns[j].type != 'charType' && !isNaN(Date.parse(value)) ) 
			                    		this.definition.columns[j].type = "dateType";
			                    	else
			                    		this.definition.columns[j].type = "charType";
			                    }
			                    else // this must be some kind of number field
			                    {
			                    	if (this.definition.columns[j].type != 'floatType' && value % 1 != 0)
			                    		this.definition.columns[j].type = 'floatType';
			                    	else
			                    		this.definition.columns[j].type = 'intType';
			                    }
			                    
			                    if (!this.definition.columns[j].length || value.length > this.definition.columns[j].length)
			                    {
			                    	this.definition.columns[j].length = value.length;
			                    }
			                    
			                    tmpRow.push({v:value});
			            	}
			                    
			            }
			            this.definition.data.push({r: tmpRow});
            		
	            	}
		            
            }
	    }
	    this.populateDBTypes();
	    this.populateWrappers();
	    return this.render();		
	}

	/* HandlebarsJS-using code below */
    
	Handlebars.registerHelper("formatted_field", function(root) {
	
		var colType = '';
		var index = -1;
		for (var j = 0; j < root.columns.length; j++)
		{
			if (root.columns[j])
				index++;
				
			if (index == this.index)
			{
				colType = root.columns[j].type;
				break;
			}
		}
		
		
		if (!this.v.length)
			return 'NULL';
		if (colType == 'charType')
			return new Handlebars.SafeString("'" + this.v.replace(/'/g, "''") + "'");
		
		if (colType == 'dateType')
			return new Handlebars.SafeString("'" + dateFormat(this.v, root.dateFormatMask) + "'");
		
		return this.v;
	});
	
	Handlebars.registerHelper("column_name_for_index", function(root) {		
		return root.columns[this.index].name;
	});
	
	
	
	Handlebars.registerHelper("each_with_index", function(array, fn) {
		var buffer = "";
		k=0;
		for (var i = 0, j = array.length; i < j; i++) {
			if (array[i])
			{
				var item = array[i];
		
				// stick an index property onto the item, starting with 0
				item.index = k;
				
				item.first = (k == 0);
				item.last = (k == array.length);
	
				// show the inside of the block
				buffer += fn(item);

				k++;
			}
		}

		// return the finished buffer
		return buffer;
	
	});		

	
	
	ddl_builder.prototype.render = function () {
		return this.compiledTemplate(this.definition);		
	}
