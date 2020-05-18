import inspect
import json
import os
import requests
import urllib

class Cotoha():
    def __init__(self, clientId, clientSecret):
        self.__clientId = clientId
        self.__clientSecret = clientSecret

    def __access(self):
        res = requests.post(
            url='https://api.ce-cotoha.com/v1/oauth/accesstokens',
            headers={
                'Content-Type': 'application/json'
            },
            data=json.dumps({
                'grantType': 'client_credentials',
                'clientId': self.__clientId,
                'clientSecret': self.__clientSecret,
            })
        )

        if res.status_code != 200 and res.status_code != 201:
            return { "err" : f"access:status is bad:{str(res.status_code)}" }

        json_data = res.json()

        if json_data["access_token"] == "":
            return { "err" : f"Authentication is failed" }

        return json_data["access_token"]

    def __common(self, param):
        access_token = self.__access()
        if 'err' in access_token:
            return { "err" : f"common:{access_token['err']}" }

        target = inspect.currentframe().f_back.f_code.co_name

        res = requests.post(
            url=f'https://api.ce-cotoha.com/api/dev/nlp/v1/{target}',
            headers={
                'Content-Type': 'application/json;charset=UTF-8',
                'Authorization':  f"Bearer {access_token}",
            },
            data=json.dumps(param)
        )

        if res.status_code != 200 and res.status_code != 201:
            return { "err" : f"common:status is bad:{str(res.status_code)}" }

        json_data = res.json()

        if json_data['status'] != 0:
            return { "err" : f"common:api status is bad:{json_data['status']}" }

        return json_data['result'] 

    def similarity(self, s1, s2, sen_type = "default", dic_type = ""):
        return self.__common(
            {
                "s1": s1,
                "s2": s2,
                "type": sen_type,
                "dic_type": dic_type,
            }
        )
