use serde_json;
use ureq::json;

pub struct Cotoha {
    pub client_id: String,
    pub client_secret: String,
}

impl Cotoha {
    pub fn new( client_id: impl Into<String>, client_secret: impl Into<String> ) -> Cotoha {
        Cotoha {
            client_id: client_id.into(),
            client_secret: client_secret.into(),
        }
    }
    
    fn __concat( &self, t1: impl Into<String>, t2: impl Into<String> ) -> String {
        t1.into() + &t2.into()
    }

    fn __access( &self ) -> Result<String, String> {
        let res = ureq::post("https://api.ce-cotoha.com/v1/oauth/accesstokens")
            .set("Content-Type", "application/json")
            .send_json(
                json!({
                    "grantType": "client_credentials",
                    "clientId": self.client_id,
                    "clientSecret": self.client_secret,
                })
            );

        if ! res.ok() {
            return Err(self.__concat("access:status is bad", res.status_line()));
        }
    
        let result = res.into_json();
        if ! result.is_ok() {
            return Err("access:Failed to parse response of cotoha api".to_string());
        }
        let json_data = result.ok().unwrap();

        let mut access_token = json_data["access_token"].to_string();
        if access_token == "" {
            return Err("access:Authentication failed for cotoha api".to_string());
        }
        access_token.retain(|c| c != '"');
    
        Ok(access_token)
    }

    fn __common( &self, api_name: &str, param: serde_json::value::Value ) -> Result<serde_json::value::Value, String> {
        let access_token = self.__access();
        if ! access_token.is_ok() {
            return Err(access_token.err().unwrap());
        }

        let url = &self.__concat("https://api.ce-cotoha.com/api/dev/nlp/v1/", api_name);
        let authorization = &self.__concat("Bearer ", access_token.ok().unwrap());

        let res = ureq::post(url)
            .set("Content-Type", "application/json;charset=UTF-8")
            .set("Authorization", authorization)
            .send_json(param);

        if ! res.ok() {
            return Err(self.__concat("common:status is bad:", res.status_line()));
        }
    
        let result = res.into_json();
        if ! result.is_ok() {
            return Err("common:Failed to parse response of cotoha api".to_string());
        }
        let json_data = result.ok().unwrap();

        let status = json_data["status"].to_string();
        if status != "0" {
            return Err(self.__concat("common:Failed to set cotoha api:", status));
        }

        Ok(json_data["result"].clone())
    }

    pub fn similarity( &self, s1: impl Into<String>, s2: impl Into<String>, sen_type: impl Into<String>, dic_type: impl Into<String> ) -> Result<serde_json::value::Value, String> {
        let mut param = json!({});
        param.as_object_mut().unwrap().insert("s1".to_string(), serde_json::to_value(s1.into()).unwrap());
        param.as_object_mut().unwrap().insert("s2".to_string(), serde_json::to_value(s2.into()).unwrap());

        let sen_type_tmp = sen_type.into();
        if sen_type_tmp != "" {
            param.as_object_mut().unwrap().insert("type".to_string(), serde_json::to_value(sen_type_tmp).unwrap());
        }
        let dic_type_tmp = dic_type.into();
        if dic_type_tmp != "" {
            param.as_object_mut().unwrap().insert("dic_type".to_string(), serde_json::to_value(dic_type_tmp).unwrap());
        }

        self.__common("similarity", param)
    }
}

