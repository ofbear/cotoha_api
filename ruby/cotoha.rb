require 'net/http'
require 'json'

class Cotoha
    @@client_id
    @@client_secret

    def initialize(client_id, client_secret)
        @@client_id = client_id
        @@client_secret = client_secret
    end

    def similarity(s1, s2, sen_type = "default", dic_type = "")
        return __common({
            "s1": s1,
            "s2": s2,
            "type": sen_type,
            "dic_type": dic_type,
        })
    end

    private

    def __access()
        u = URI.parse("https://api.ce-cotoha.com/v1/oauth/accesstokens")
        h = Net::HTTP.new(u.host, u.port)
        h.use_ssl = true
        res = h.post(
            u.path,
            {
                "grantType": "client_credentials",
                "clientId": @@client_id,
                "clientSecret": @@client_secret,
            }.to_json,
            {
                "Content-Type" => "application/json"
            },
        )

        if res.code != "200" and res.code != "201" then
            return { "err" => "access:status is bad:" + res.code }
        end

        json_data = JSON.parse(res.body)

        if ! json_data.has_key?("access_token") then
            return { "err" => "access:Authentication is failed" }
        end

        return json_data
    end

    def __common(param)
        result = __access()
        if result.has_key?("err") then
            return { "err" => "common:" + result["err"] }
        end
        access_token = result["access_token"]

        target = caller[0][/`([^']*)'/, 1]

        u = URI.parse("https://api.ce-cotoha.com/api/dev/nlp/v1/#{target}")
        h = Net::HTTP.new(u.host, u.port)
        h.use_ssl = true
        res = h.post(
            u.path,
            param.to_json,
            {
                "Content-Type" => "application/json;charset=UTF-8",
                "Authorization" => "Bearer #{access_token}",
            } 
        )

        if res.code != "200" and res.code != "201" then
            return { "err" => "common:status is bad:" + res.code }
        end

        json_data = JSON.parse(res.body)

        if json_data["status"] != 0 then
            return { "err" => "common:api status is bad:" + json_data["status"] }
        end

        return json_data["result"]
    end

end

