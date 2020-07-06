module cotoha

import json
import net.http

pub struct Cotoha {
	client_id     string
	client_secret string
}

pub fn new_cotoha(c Cotoha) &Cotoha {
	return &Cotoha {
		client_id: c.client_id
		client_secret: c.client_secret
	}
}

struct StAccess {
	access_token string
	token_type   string
	expires_in   string
	scope        string
	issued_at    string
}

fn (c Cotoha) json_encode(m map[string]string) string {
	mut ret := "{"
	for k, v in m {
		ret += '"$k":"$v",'
	}
	ret = ret.trim_right(",")
	ret += "}"

	return ret
}

fn (c Cotoha) access() ?string {
	resp := http.fetch(
		"https://api.ce-cotoha.com/v1/oauth/accesstokens",
		{
			method: "POST",
			data: c.json_encode({
				"grantType": "client_credentials",
				"clientId": "$c.client_id",
				"clientSecret": "$c.client_secret"
			}),
			headers: {
				"Content-Type": "application/json"
			}
		}
	)?

	decoded := json.decode(StAccess, resp.text)?

	return decoded.access_token
}

fn (c Cotoha) common(target string, data map[string]string) ?string {
	access_token := c.access()?

	resp := http.fetch(
		"https://api.ce-cotoha.com/api/dev/nlp/v1/" + target,
		{
			method: "POST",
			data: c.json_encode(data),
			headers: {
				"Content-Type": "application/json;charset=UTF-8",
				"Authorization": "Bearer " + access_token,
			}
		}
	)?

	return resp.text
}

struct StSimilarityResult {
pub:
	score f64
}

struct StSimilarity {
pub:
	result  StSimilarityResult
	status  int
	message string
}

pub fn (c Cotoha) similarity(s1 string, s2 string, senType string, dicType string) ?StSimilarity {
	mut data := {
		"s1": s1,
		"s2": s2,
	}
	if senType != "" {
		data["type"] = senType
	}
	if dicType != "" {
		data["dic_type"] = dicType
	}

	result := c.common("similarity", data)?

	decoded := json.decode(StSimilarity, result)?

	return decoded
}
