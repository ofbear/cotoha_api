package cotoha

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"net/http"
	"encoding/json"
)

// Cotoha ...
type Cotoha struct {
	clientID     string
	clientSecret string
}

// NewCotoha ...
func NewCotoha(clientID string, clientSecret string) *Cotoha {
	c := new(Cotoha)
	c.clientID = clientID
	c.clientSecret = clientSecret
	return c
}

func (c *Cotoha) makeResult(data interface{}, result interface{}) (err error) {
	m, ok := data.(map[string]interface{})
	if !ok {
		return fmt.Errorf("makeResult:data isn't map")
	}

	j, err := json.Marshal(m)
	if err != nil {
		return fmt.Errorf("makeResult:%s", err.Error())
	}
	err = json.Unmarshal(j, result)
	if err != nil {
		return fmt.Errorf("makeResult:%s", err.Error())
	}

	return nil
}

func (c *Cotoha) post(url string, header map[string]string, param map[string]string) (result []byte, err error) {
    jsonData, err := json.Marshal(param)
    if err != nil {
		return nil, fmt.Errorf("post:%s", err.Error())
    }

	req, err := http.NewRequest(
		http.MethodPost,
		url,
		bytes.NewBuffer(jsonData),
	)
	if err != nil {
		return nil, fmt.Errorf("post:%s", err.Error())
	}
	for k, v := range header {
		req.Header.Set(k, v)
	}

	client := &http.Client{}
	res, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("post:%s", err.Error())
	}
	defer res.Body.Close()

	if res.StatusCode != 200 && res.StatusCode != 201 {
		return nil, fmt.Errorf("post:status is bad:%d", res.StatusCode)
	}

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return nil, fmt.Errorf("post:%s", err.Error())
	}

	return body, nil
}

// StAccessTokensResponse ...
type StAccessTokensResponse struct {
	AccessToken string `json:"access_token"`
	TokenType   string `json:"token_type"`
	ExpiresIn   string `json:"expires_in"`
	Scope       string `json:"scope"`
	IssuedAt    string `json:"issued_at"`
}

func (c *Cotoha) access() (accessToken string, err error) {
	body, err := c.post(
		"https://api.ce-cotoha.com/v1/oauth/accesstokens",
		map[string]string{
			"Content-Type":  "application/json",
		},
		map[string]string{
			"grantType":  "client_credentials",
			"clientId":  c.clientID,
			"clientSecret":  c.clientSecret,
		},
	)
	if err != nil {
		return "", fmt.Errorf("access:%s", err.Error())
	}

	var token StAccessTokensResponse
	err = json.Unmarshal(body, &token)
	if err != nil {
		return "", fmt.Errorf("access:%s", err.Error())
	}
	if token.AccessToken == "" {
		return "", fmt.Errorf("access:Authentication failed")
	}

	return token.AccessToken, nil
}

// StCommonResponse ...
type StCommonResponse struct {
	Result  interface{} `json:"result"`
	Status  int         `json:"status"`
	Message string      `json:"message"`
}

func (c *Cotoha) common(target string, param map[string]string) (result interface{}, err error) {
	token, err := c.access()
	if err != nil {
		return nil, fmt.Errorf("common:%s", err.Error())
	}

	body, err := c.post(
		"https://api.ce-cotoha.com/api/dev/nlp/v1/"+target,
		map[string]string{
			"Content-Type":  "application/json;charset=UTF-8",
			"Authorization":  "Bearer " + token,
		},
		param,
	)
	if err != nil {
		return nil, fmt.Errorf("common:%s", err.Error())
	}

	var common StCommonResponse
	err = json.Unmarshal(body, &common)
	if err != nil {
		return nil, fmt.Errorf("common:%s", err.Error())
	}
	if common.Status != 0 {
		return nil, fmt.Errorf("common:status is bad:%d", common.Status)
	}

	return common.Result, nil
}

// StSimilarityResponse ...
type StSimilarityResponse struct {
	Score float64 `json:"score"`
}

// Similarity ...
func (c *Cotoha) Similarity(s1 string, s2 string, senType string, dicType string) (result StSimilarityResponse, err error) {
	param := map[string]string{
		"s1": s1,
		"s2": s2,
	}
	if senType != "" {
		param["type"] = senType
	}
	if dicType != "" {
		param["dic_type"] = dicType
	}

	res, err := c.common("similarity", param)
	if err != nil {
		return result, err
	}

	err = c.makeResult(res, &result)
	if err != nil {
		return result, err
	}

	return result, nil
}
