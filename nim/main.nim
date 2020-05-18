import cotoha
import json

var c: Cotoha = Cotoha()
c.init("clientId", "clientSecret")
var result: JsonNode = c.similarity("test", "test")

echo result.pretty()
