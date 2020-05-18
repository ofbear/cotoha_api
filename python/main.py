import json
import os

from cotoha import Cotoha

c = Cotoha("clientId", "clientSecret")
result = c.similarity("test", "test")

print("{}".format(json.dumps(result,indent=4)))
