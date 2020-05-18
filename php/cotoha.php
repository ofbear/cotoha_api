<?php
class Cotoha
{
    public function __construct(string $client_id, string $client_secret)
    {
        $this->__client_id = $client_id;
        $this->__client_secret = $client_secret;
    }

    private function __post(string $url, array $header, array $param)
    {
        $option = array(
            CURLOPT_TIMEOUT => 30,
            CURLOPT_HEADER => TRUE,
            CURLOPT_RETURNTRANSFER => TRUE,
            CURLOPT_SSL_VERIFYPEER => FALSE,
            CURLOPT_SSL_VERIFYHOST => FALSE,
            CURLOPT_POST => TRUE,
            CURLOPT_URL => $url,
            CURLOPT_HTTPHEADER => $header,
            CURLOPT_POSTFIELDS => json_encode($param),
        );

        $ch = curl_init();
        curl_setopt_array($ch, $option);

        $res =  curl_exec($ch);
        $info = curl_getinfo($ch);
        $errorNo = curl_errno($ch);

        if ($errorNo != CURLE_OK) {
            return array( 'err' => "post:status is bad:${errorNo}" );
        }

        curl_close($ch);

        $this->header = substr($res, 0, $info["header_size"]);
        $this->body = substr($res, $info["header_size"]);

        $ret = json_decode($this->body, true);

        return $ret;
    }

    private function __access()
    {
        $result = $this->__post(
            'https://api.ce-cotoha.com/v1/oauth/accesstokens',
            array(
                'Content-Type: application/json',
            ),
            array(
                'grantType' => 'client_credentials',
                'clientId' => $this->__client_id,
                'clientSecret' => $this->__client_secret,
            )
        );

        if( isset($result["err"]) ) {
            return array( 'err' => "access:${result['err']}" );
        }
        if( !isset( $result["access_token"] ) ) {
            return array( 'err' => "access:Authentication is failed" );
        }

        return $result["access_token"];
    }

    private function __common(array $param)
    {
        $access_token = $this->__access();
        if( isset($access_token["err"]) ) {
            return array( 'err' => "common:${access_token['err']}" );
        }

        $target = debug_backtrace()[1]['function'];

        $result = $this->__post(
            'https://api.ce-cotoha.com/api/dev/nlp/v1/' . $target,
            array(
                'Content-Type: application/json;charset=UTF-8',
                'Authorization: Bearer ' . $access_token,
            ),
            $param
        );

        if( isset($result["err"]) ) {
            return array( 'err' => "common:${result['err']}" );
        }

        if( $result["status"] != 0 ) {
            return array( 'err' => "common:status is bad:${result['status']}" );
        }

        return $result["result"];
    }

    public function similarity(string $s1, string $s2, string $sen_type = "default", string $dic_type = "")
    {
        return $this->__common(array(
            "s1" => $s1,
            "s2" => $s2,
            "type" => $sen_type,
            "dic_type" => $dic_type,
        ));
    }
}

?>
