# COTOHAとは
日本最大級の日本語辞書を活用　自然言語処理音声認識APIプラットフォーム
https://api.ce-cotoha.com/contents/index.html

# 目的
各言語のライブラリがあったら便利ではないかと思った。以上。

# 言語
- go
- nim
- rust
- python
- php
- ruby
- sh

# 見方
各言語フォルダに入っている「main」がサンプル。
基本的には「Cotoha」クラスにクライアントIDと鍵を入れて呼び出し、
使いたいAPIと同名の関数にパラメータを投げればOK。
全てのAPIを用意するのは大変なので、サンプルとして類似度のみ実装。
その他のAPIが使いたい場合、類似度に倣って関数実装のこと。

# ライセンス
MIT