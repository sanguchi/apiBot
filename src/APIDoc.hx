class APIDoc {
  public static var methods: Array<MethodType> =  haxe.Json.parse(haxe.Resource.getString("JSONTMethods"));
  public static var types: Array<APIType> =  haxe.Json.parse(haxe.Resource.getString("JSONTypes"));
  public static var returns: Array<ReturnType> =  haxe.Json.parse(haxe.Resource.getString("JSONReturns"));

  public static function generateInlineResultsForEmptyQuery() {
    return;
  }

  public static function generateInlineResultsForMethodQuery(methodName: String) {
    return;
  }

  public static function generateInlineResultsForTypeQuery(typeName: String) {
    return;
  }
}

typedef MethodDesc = {
  name: String,
  field_type: String,
  required: Bool,
  description: String,
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

typedef MethodType = {
  name: String,
  description: String,
  fields: Array<MethodField>,
}

typedef ReturnType = {
  method_name: String,
  method_return: String,
}
