import telehx.TeleHxTypes;
import telehx.TeleHxBot;
using telehx.TeleHxMethods;
import APIDoc;
class BotHandler {

  var bot: TeleHxBot;
  var chunkResultSize: Int = 12;
  var apiDoc: APIDoc = new APIDoc();
  // var inlineHandler: HxUpdate -> Bool =
  public function startHandler(update: HxUpdate): Bool {
    trace('[startHandler]: Handling update ${update.update_id}');
    switch(update) {

      case {message : {text: text}} if(update.message  != null && text != null): {
        trace('[startHandler]: Handling message ${update.message.message_id}: $text');
        switch(text) {

          case "/start" | "/help" | "/start start": {
            bot.sendMessage({
              chat_id: update.message.chat.id,
              text: "This bot works on inline mode, use it to query telegram bot api docs\nSource:\n - https://github.com/sanguchi/apiBot",
              reply_markup: {
                inline_keyboard: [[{
                  text: "Test it",
                  switch_inline_query_current_chat: "sendMessage",
                  }]]
                },
              });
            return false;
          }

          case _ : {
            return true;
          }
        }
      }

      case _ : {
        return true;
      }
    }
  }
	
	function callbackHandler(update: HxUpdate): Bool {
		trace('[callbackHancler]: Handle update id: ${update.update_id}');
		switch(update) {
			case {callback_query: callback_query} if (callback_query != null): {
				trace('Callback query received: [${callback_query.data}]');
				var delimited: Int = callback_query.data.toLowerCase().indexOf(':');
				if (callback_query.data.toLowerCase().indexOf(':') != -1) {
					var action: String = callback_query.data.toLowerCase().substring(0, delimited);
					var value: String = callback_query.data.substring(delimited +1);
					trace('action: $action - value $value');
					switch(action) {
						case "details": {
							trace('Building detail for value $value');
							var methodTest: MethodDesc = apiDoc.getMethod(value);
							var apiTypeTest: APIType = apiDoc.getType(value);
							var descText: String;
							if (methodTest != null) {
								trace('Method detected: ${methodTest.method_name}');
								descText = apiDoc.generateDetailsMessage(methodTest).message_text;
							}
							else if (apiTypeTest != null) {
								trace('APIType detected: ${apiTypeTest.api_type_name}');
								descText = apiDoc.generateDetailsMessage(apiTypeTest).message_text;
							}
							else {
								trace('No result for $value');
								return true;
							}
							var params: HxeditMessageText = {
								inline_message_id: callback_query.inline_message_id,
								text: descText,
								parse_mode: "HTML",
								reply_markup: {
									inline_keyboard: [[{
										text: "Back to summary",
										callback_data: 'summary:$value',
									}]]
                },
							};
							TeleHxMethods.editMessageText(bot, params);
						}
						case "summary": {
							trace('Building summary for value $value');
							var methodTest: MethodDesc = apiDoc.getMethod(value);
							var apiTypeTest: APIType = apiDoc.getType(value);
							var descText: String;
							var buttonText: String;
							if (methodTest != null) {
								descText = apiDoc.generateSummaryMessage(methodTest.method_name, null).message_text;
								buttonText = "Method details";
							}
							else if (apiTypeTest != null) {
								descText = apiDoc.generateSummaryMessage(null, apiTypeTest.api_type_name).message_text;
								buttonText = "Object details";
							}
							else {
								return true;
							}
							var params: HxeditMessageText = {
								inline_message_id: callback_query.inline_message_id,
								text: descText,
								parse_mode: "HTML",
								reply_markup: {
									inline_keyboard: [[{
										text: buttonText,
										callback_data: 'details:$value',
                  }]]
                },
							};
							TeleHxMethods.editMessageText(bot, params);
						}
					}
					return false;
				}
			}
		}
		return true;
	}
	
  function inlineHandler(update: HxUpdate): Bool {
    trace('[inlineHandler]: Handle update id: ${update.update_id}');
    var resultHeader: String = "More info";
    var offset: String = "";
    var response: Array<HxInlineQueryResult> = [];

    switch(update) {
      case {inline_query: inline_query} if(inline_query  != null): {
        // Let's cringe :^)
        trace('Inline query received: [${inline_query.query}]');
        switch(inline_query.query.toLowerCase()) {
          // Return list with all known types.
          case "types" | "type" | "typ" | "ty" | "t" : {
            trace('User requested all Types.');
            response = apiDoc.generateInlineResultsForTypes();
          }
          // Return list with all known methods.
          case "methods" | "method" | "metho" | "meth" | "met" | "me" | "m" : {
            trace('User requested all methods');
            response = apiDoc.generateInlineResultsForMethods();
          }
          // Return everything.
          case "" : {
            trace('User requested everything');
            response = apiDoc.generateInlineResultsForEmptyQuery();
          }
          case query : {
            trace('User requested $query');
            response = apiDoc.generateInlineResultsForGivenQuery(query);
          }
        }
        // Handle offsets using chunk size * offset.
        // if result is greater than array size, return array.
        // if result is less than array size, return subarray starting from result.
        trace('Results: ${response.length}');
        var cursor: Null<Int> = Std.parseInt(inline_query.offset);
        cursor = cursor != null? cursor : 0;
        if(response.length > chunkResultSize) {
          trace('Splicing ${response.length} results: $cursor * $chunkResultSize');
          response.splice(0, chunkResultSize * cursor); // = response.slice(cursor * chunkResultSize, chunkResultSize);
          if(response.length >= chunkResultSize) {
            response.splice(chunkResultSize, response.length - chunkResultSize);
            offset = Std.string(cursor + 1);
            trace('incrementing offset to $offset');
          }
        }
        trace('Sending ${response.length} results');

        // Set offset based on array size.
        // If array is greater than chunk size, slice array
        // and set offset to received offset + 1 or 1 if offset was null.


        if(response.length == 0) {
          resultHeader = "Nothing found.";
        }
        // trace('[inlineHandler]: response: $response');
        // Answer query.
        bot.answerInlineQuery(
          {
            inline_query_id: inline_query.id,
            results: response,
            next_offset: offset,
            switch_pm_text: resultHeader,
            switch_pm_parameter: "start",
          });
        return false;
      }
      case _ :
        return true;
    }
  }
  public function new(bot: TeleHxBot) {
    this.bot = bot;
    this.bot.addHandler(this.startHandler);
    this.bot.addHandler(this.inlineHandler);
		this.bot.addHandler(this.callbackHandler);
  }
}
