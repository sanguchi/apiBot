import telehx.TeleHxTypes;
using telehx.TeleHxMethods;
using StringTools;

class APIDoc {
  var methods: Array<MethodDesc> = haxe.Json.parse(haxe.Resource.getString("METHODS"));
  var types: Array<APIType> =  haxe.Json.parse(haxe.Resource.getString("TYPES"));
  var returns: Array<ReturnType> =  haxe.Json.parse(haxe.Resource.getString("RETURNS"));
	
	public function new() {
		
		#if debug
		
		trace('Testing typedefs');
		var myMethod: Dynamic = this.getMethod('getMe');
		trace('method: ${myMethod.method_name}');
		var myApiType: Dynamic = this.getType('User');
		trace('type: ${myApiType.api_type_name}');
		if (myMethod.method_name != null) {
			trace('${myMethod.method_name} is a method, !null? ${myMethod.method_name != null}');
		} else {
			trace('${myMethod.api_type_name} is a type, !null? ${myMethod.api_type_name != null}');
		}
		if (myApiType.api_type_name != null) {
			trace('${myApiType.api_type_name} is a type !null? ${myApiType.api_type_name != null}');
		} else {
			trace('${myApiType.method_name} is a method, !null? ${myApiType.method_name != null}');
		}
		trace(myMethod.method_name);
		trace(myMethod.api_type_name);
		trace(myApiType.method_name);
		trace(myApiType.api_type_name);
		trace(myApiType);
		trace(myMethod);
		
		#end
		
		/*
		switch(myMethod) {
			case APIType = apiType: {
				trace('${apiType.api_type_name} is a type');
			}
			case MethodDesc = method: {
				trace('${myMethod.method_name} is a method');
			}
		}
		switch(myApiType) {
			case APIType = apiType: {
				trace('${apiType.api_type_name} is a type');
			}
			case MethodDesc = method: {
				trace('${method.method_name} is a method');
			}
		}
		*/
	}
	
	public function getMethod(query: String): Null<MethodDesc> {
		for (method in methods) {
			if (method.method_name == query) {
				return method;
			}
		}
		return null;
	}
	
	public function getType(query: String): Null<APIType> {
		for (apiType in types) {
			if (apiType.api_type_name == query) {
				return apiType;
			}
		}
		return null;
	}
	
  // Returns array with all methods and types.
  public function generateInlineResultsForEmptyQuery(): Array<HxInlineQueryResultArticle> {
    var results: Array<HxInlineQueryResultArticle> = [];
    for(method in methods) {
      results.push(generateInlineQueryResultArticle(Std.string(results.length), method.method_name, method));
    }
    for(apiType in types) {
      results.push(generateInlineQueryResultArticle(Std.string(results.length), apiType.api_type_name, apiType));
    }
    return results;
  }

  public function generateInlineResultsForGivenQuery(query: String): Array<HxInlineQueryResultArticle> {
    var results: Array<HxInlineQueryResultArticle> = [];
    for(method in methods) {
      if(method.method_name.toLowerCase().indexOf(query) != -1) {
        results.push(generateInlineQueryResultArticle(Std.string(results.length), method.method_name, method));
      }
    }
    for(apiType in types) {
      if(apiType.api_type_name.toLowerCase().indexOf(query) != -1) {
        results.push(generateInlineQueryResultArticle(Std.string(results.length), apiType.api_type_name, apiType));
      }
    }
    return results;
  }

  public function generateInlineResultsForTypes(): Array<HxInlineQueryResultArticle> {
    var results: Array<HxInlineQueryResultArticle> = [];
    for(apiType in types) {
      results.push(generateInlineQueryResultArticle(Std.string(results.length), apiType.api_type_name, apiType));
    }
    return results;
  }

  public function generateInlineResultsForMethods(): Array<HxInlineQueryResultArticle> {
    var results: Array<HxInlineQueryResultArticle> = [];
    for(method in methods) {
      results.push(generateInlineQueryResultArticle(Std.string(results.length), method.method_name, method));
    }
    return results;
  }
  // Generates an instance of Article to append to the result array.
  public function generateInlineQueryResultArticle(i: String, title: String, obj: Dynamic, ?details: Bool = false): HxInlineQueryResultArticle {
    // trace('[generateInlineQueryResultArticle]: details: $details');
		// trace('[generateInlineQueryResultArticle]: obj: $obj');
    var content: HxInputMessageContent;
    if(details) {
      content = generateDetailsMessage(obj);
    }
    else {
			if (obj.method_name != null) {
				content = generateSummaryMessage(obj.method_name, null);
			} else {
				content = generateSummaryMessage(null, obj.api_type_name);
			}
			/*
			switch(obj) {
				case MethodDesc = method: {
					content = generateSummaryMessage(method.method_name);
				}
				case APIType = apiType: {
					
					content = generateSummaryMessage(apiType.api_type_name);
				}
			}
      */
    }
    // trace('[generateInlineQueryResultArticle]: content: $content');
		var inlineButtonText: String = details? 'Summary': 'Details';
		
		var callback_data_string: String;
		if (obj.method_name != null) {
			callback_data_string = details? 'summary:${obj.method_name}': 'details:${obj.method_name}';
		} else {
			callback_data_string = details? 'summary:${obj.api_type_name}': 'details:${obj.api_type_name}';
		}
		
		/*
		switch(obj) {
			case MethodDesc = method: {
				callback_data_string = details? 'summary:${method.method_name}': 'details:${method.method_name}';
			}
			case APIType = apiType: {
				callback_data_string = details? 'summary:${apiType.api_type_name}': 'details:${apiType.api_type_name}';
			}
		}
		*/
		
		// var callback_data_string: String = details? 'summary:${obj.name}': 'details:${obj.name}';
    var response: HxInlineQueryResultArticle = {
      type: "article",
      id: i,
      title: title,
      input_message_content: content,
			reply_markup: {
        inline_keyboard: [[{
				text: inlineButtonText,
				callback_data: callback_data_string,
        }]]
      },
    };
    return response;
  }

  public function generateSummaryMessage(?method_name: String, ?api_type_name: String): HxInputTextMessageContent {
    trace('[generateSummaryMessage]: method_name = $method_name - api_type_name = $api_type_name');
		var name: String;
		var desc: String;
		if (method_name != null) {
			name = method_name;
			desc = this.getMethod(method_name).method_description.htmlEscape(true);
		}
		else {
			name = api_type_name;
			desc = this.getType(api_type_name).api_type_description.htmlEscape(true);
		}
		/*
		switch(obj) {
      case {method_name: method_name, description: description, fields: fields}: {
				var desc: String = StringTools.htmlEscape(description, true);
				trace('[Summary] Detected method ${method_name}');
        return {
          // message_text: '<b>${method.name}</b>\n<pre>${method.description}</pre>',
          message_text: '<b>${method_name}</b>\n<pre>  ${desc}</pre>',
          parse_mode: "HTML",
          disable_web_page_preview: true,
        };
      }
      case APIType = apiType: {
				trace('[Summary] Detected apiType ${apiType.api_type_name}');
				var desc: String = StringTools.htmlEscape(apiType.description, true);
        return {
          // message_text: '<b>${apiType.name}</b>\n<pre>${apiType.description.htmlEscape()}</pre>',
					message_text: '<b>${apiType.api_type_name}</b>\n<pre>  ${desc}</pre>',
          parse_mode: "HTML",
          disable_web_page_preview: true,
        };
      }
    }
		*/
    return {message_text: '<b>${name}</b>\n<pre>  ${desc}</pre>', parse_mode: "HTML", disable_web_page_preview: true};
  }

  public function generateDetailsMessage(obj: Dynamic): HxInputTextMessageContent {
		if (obj.method_name != null) {
			var details: StringBuf = new StringBuf();
			trace('[generateDetailsMessage] Method ${obj.method_name} fields: ${obj.method_fields.length}');
			var fields: Array<MethodField> = obj.method_fields;
			for (field in fields) {
				var parsed_desc = StringTools.htmlEscape(field.method_field_description, true);
				trace('[generateDetailsMessage]: Adding field ${field.method_field_parameter} to method ${obj.method_name}');
				details.add('|-<i>${field.method_field_parameter}</i> : (${field.method_field_type})\n<pre>  ${parsed_desc}</pre>\n');
			}
      return {
				message_text: '<b>${obj.method_name} details:</b>\n${details.toString()}',
        parse_mode: "HTML",
        disable_web_page_preview: true,
      };
		}
		else {
			var details: StringBuf = new StringBuf();
			var fields: Array<TypeField> = obj.api_type_fields;
			trace('[generateDetailsMessage] APIType ${obj.api_type_name} fields ${obj.api_type_fields.length}');
			for (field in fields) {
				var parsed_desc = StringTools.htmlEscape(field.api_type_field_description, true);
				details.add('|-<i>${field.api_type_field_name}</i> : ${field.api_type_field_type}\n<pre>  ${parsed_desc}</pre>\n');
			}
      return {
				message_text: '<b>${obj.api_type_name} details:</b>\n${details.toString()}',
        parse_mode: "HTML",
        disable_web_page_preview: true,
      };
		}
		/*
    switch(obj) {
      case MethodDesc = method: {
				var details: StringBuf = new StringBuf();
				trace('[Detail] Method ${method.method_name} fields: ${method.method_fields.length}');
				var fields: Array<MethodField> = method.method_fields;
				for (field in fields) {
					var parsed_desc = StringTools.htmlEscape(field.method_field_description, true);
					trace('[Detail]: Adding field ${field.method_field_parameter} to method ${method.method_name}');
					details.add('|-<i>${field.method_field_parameter}</i> : (${field.method_field_type})\n<pre>  ${parsed_desc}</pre>\n');
				}
        return {
					message_text: '<b>${method.method_name} details:</b>\n${details.toString()}',
          parse_mode: "HTML",
          disable_web_page_preview: true,
        };
      }
      case APIType = apiType: {
				var details: StringBuf = new StringBuf();
				var fields: Array<TypeField> = apiType.api_type_fields;
				trace('[Detail] APIType ${apiType.api_type_name} fields ${apiType.api_type_fields.length}');
				for (field in fields) {
					var parsed_desc = StringTools.htmlEscape(field.api_type_field_description, true);
					details.add('|-<i>${field.api_type_field_name}</i> : ${field.api_type_field_type}\n<pre>  ${parsed_desc}</pre>\n');
				}
        return {
					message_text: '<b>${apiType.api_type_name} details:\n${details.toString()}',
          parse_mode: "HTML",
          disable_web_page_preview: true,
        };
      }
    }
		*/
    return {message_text: '<b>ERROR</b>\n - <i>ERROR</i>', parse_mode: "HTML", disable_web_page_preview: true};
  }
}

typedef TypeField = {
  api_type_field_name: String,
  api_type_field_type: String,
  api_type_field_description: String,
	api_type_field_required: Bool,
}

typedef APIType = {
  api_type_name: String,
  api_type_description: String,
  api_type_fields: Array<TypeField>,
}

typedef MethodField = {
  method_field_parameter: String,
  method_field_type: String,
  method_field_required: Bool,
  method_field_description: String,
}

typedef MethodWrap = {
  methods: Array<MethodDesc>,
}
typedef MethodDesc = {
  method_name: String,
  method_description: String,
  method_fields: Array<MethodField>,
}

typedef ReturnType = {
  method_name: String,
  method_return: String,
}
