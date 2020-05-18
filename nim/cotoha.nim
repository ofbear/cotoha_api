import class
import json
import httpclient
import strformat
import strutils

class Cotoha:
    var clientId: string
    var clientSecret: string

    proc init*(clientId: string, clientSecret: string) =
        self.clientId = clientId
        self.clientSecret = clientSecret

    proc post(url: string, header: openArray[tuple[key: string, val: string]], param: JsonNode): JsonNode =
        var client = newHttpClient()
        client.headers = newHttpHeaders(header)
        var res: Response = client.request(
            url = url,
            httpMethod = HttpPost,
            body = $param
        )

        if not res.status.contains("200") and not res.status.contains("201"):
            return %*{ "err": fmt"post:status is bad:{res.status}" }

        try:
            return parseJson(res.body)

        except:
            return %*{ "err": fmt"post:parseJson is failed" }

    proc access(): JsonNode =
        return self.post(
            "https://api.ce-cotoha.com/v1/oauth/accesstokens",
            {
                "Content-Type": "application/json",
            },
            %*{
                "grantType": "client_credentials",
                "clientId": self.clientId,
                "clientSecret": self.clientSecret,
            }
        )

    proc common(target: string, param: JsonNode): JsonNode =
        result = parseJson("{}")

        result = self.access()
        if result.hasKey("err"):
            return %*{ "err": fmt"access:{$result[""err""].getStr()}" }

        let access_token: string = $result["access_token"].getStr()

        result = self.post(
            fmt"https://api.ce-cotoha.com/api/dev/nlp/v1/{target}",
            {
            "Content-Type" : "application/json;charset=UTF-8",
            "Authorization" :  fmt"Bearer {access_token}",
            },
            param
        )
        if result.hasKey("err"):
            return %*{ "err": fmt"common:{$result[""err""].getStr()}" }

        if $result["status"] != "0":
            return %*{ "err": fmt"common:api settings are wrong:{$result[""status""]}" }

    proc similarity*(s1: string, s2: string, sen_type: string = "default", dic_type: string = ""): JsonNode =
        return self.common(
            "similarity",
            %*{
                "s1": s1,
                "s2": s2,
                "type": sen_type,
                "dic_type": dic_type,
            }
        )

