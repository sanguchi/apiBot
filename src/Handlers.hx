import telehx.TeleHxTypes;

class BotHandler {

  public static var inlineHandler: HxUpdate -> Bool = function(update: HxUpdate): Bool {
    switch(update) {
      case {inline_query: inline_query} if(inline_query  != null): {
        if(hasAPIMethod(inline_query.query)) {
          // Call method to get method results.
          response =
        }
        else if(hasAPIType(inline_query.query)) {
          // Call method to get type results
        }
        else {
          // Call method to build empty response.
        }
      }
    }
  }
  // Check if query is a valid api method.
  public static function hasAPIMethod(APImethod: String): Bool {

  }
  // Check if query is a valid api Type.
  public static function hasAPIType(APIType: String): Bool {

  }
  // Returns a method detail message.
  public static function getAPIMethod(method: String) {

  }
}
