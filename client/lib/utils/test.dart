void main() {
  testCall();
}

void testCall() {
  String method = "handle";
  List<Object> args = [
    10,
    "hello",
    {
      "a": {"b": true}
    },
    false,
    3.14
  ];
  List<String> argStr = [];
  for (Object obj in args) {
    if (obj is String) {
      argStr.add("\"$obj\"");
    } else {
      argStr.add(obj.toString());
    }
  }
  print("$method(${argStr.join(",")})");
}

void testCreate() {
  RegExp _createReg = RegExp(
      r"CREATE * TABLE * IF* NOT * EXISTS* (.*) \(|CREATE *TABLE *(.*) \(");
  String input = """
            CREATE TABLE IF NOT EXISTS tasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              name TEXT NOT NULL,
              desc TEXT NOT NULL,
              startAt INTEGER NOT NULL, 
              endAt INTEGER NOT NULL
            )
          """;
  for (var m in _createReg.allMatches(input)) {
    print(m.group(0));
  }
}
