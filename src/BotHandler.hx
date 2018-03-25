import telehx.TeleHxTypes;
import telehx.TeleHxBot;
using telehx.TeleHxMethods;
class BotHandler {

  var bot: TeleHxBot;
  var chunkResultSize: Int = 8;
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
                  switch_inline_query_current_chat: "getMe",
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
  }
}
