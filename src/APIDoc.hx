import telehx.TeleHxTypes;
using telehx.TeleHxMethods;

class APIDoc {
  var methods: Array<MethodDesc> = haxe.Json.parse(haxe.Resource.getString("METHODS"));
  var types: Array<APIType> =  haxe.Json.parse(haxe.Resource.getString("TYPES"));
  var returns: Array<ReturnType> =  haxe.Json.parse(haxe.Resource.getString("RETURNS"));

  // Returns array with all methods and types.
  public function generateInlineResultsForEmptyQuery(): Array<HxInlineQueryResultArticle> {
    var results: Array<HxInlineQueryResultArticle> = [];
    for(method in methods) {
      results.push(generateInlineQueryResultArticle(Std.string(results.length), method.name, method));
    }
    for(apiType in types) {
      results.push(generateInlineQueryResultArticle(Std.string(results.length), apiType.name, apiType));
    }
    return results;
  }

  public function generateInlineResultsForGivenQuery(query: String): Array<HxInlineQueryResultArticle> {
    var results: Array<HxInlineQueryResultArticle> = [];
    for(method in methods) {
      if(method.name.toLowerCase().indexOf(query) != -1) {
        results.push(generateInlineQueryResultArticle(Std.string(results.length), method.name, method));
      }
    }
    for(apiType in types) {
      if(apiType.name.toLowerCase().indexOf(query) != -1) {
        results.push(generateInlineQueryResultArticle(Std.string(results.length), apiType.name, apiType));
      }
    }
    return results;
  }

  public function generateInlineResultsForTypes(): Array<HxInlineQueryResultArticle> {
    var results: Array<HxInlineQueryResultArticle> = [];
    for(apiType in types) {
      results.push(generateInlineQueryResultArticle(Std.string(results.length), apiType.name, apiType));
    }
    return results;
  }

  public function generateInlineResultsForMethods(): Array<HxInlineQueryResultArticle> {
    var results: Array<HxInlineQueryResultArticle> = [];
    for(method in methods) {
      results.push(generateInlineQueryResultArticle(Std.string(results.length), method.name, method));
    }
    return results;
  }
  // Generates an instance of Article to append to the result array.
  public function generateInlineQueryResultArticle(i: String, title: String, obj: Dynamic, ?details: Bool = false): HxInlineQueryResultArticle {
    trace('[article]: details: $details');
    var content: HxInputMessageContent;
    if(details) {
      content = generateDetailsMessage(obj);
    }
    else {
      content = generateSummaryMessage(obj);
    }
    // trace('[article]: content: $content');
    var response: HxInlineQueryResultArticle = {
      type: "article",
      id: i,
      title: title,
      input_message_content: content,
    };
    return response;
  }

  public function generateSummaryMessage(obj: Dynamic): HxInputMessageContent {
    switch(obj) {
      case MethodDesc = method: {
        return {
          message_text: '<b>${method.name}</b>\n - <pre>${method.description}</pre>',
          // parse_mode: "HTML",
          disable_web_page_preview: true,
        };
      }
      case APIType = apiType: {
        return {
          message_text: '<b>${apiType.name}</b>\n - <pre>${apiType.description}</pre>',
          // parse_mode: "HTML",
          disable_web_page_preview: true,
        };
      }
    }
    return {message_text: '<b>ERROR</b>\n - <i>ERROR</i>', parse_mode: "HTML", disable_web_page_preview: true};
  }

  public function generateDetailsMessage(obj: Dynamic): HxInputMessageContent {
    return {};
  }

  public function new() {
  }
}

typedef TypeField = {
  field: String,
  field_type: String,
  description: String,
}

typedef APIType = {
  name: String,
  description: String,
  fields: Array<TypeField>,
}

typedef MethodField = {
  parameter: String,
  field_type: String,
  required: Bool,
  description: String,
}

typedef MethodWrap = {
  methods: Array<MethodDesc>,
}
typedef MethodDesc = {
  name: String,
  description: String,
  fields: Array<MethodField>,
}

typedef ReturnType = {
  method_name: String,
  method_return: String,
}
