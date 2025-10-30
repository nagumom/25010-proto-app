# 25010-proto-app

## 概要

AWSをインフラにしたWebアプリケーションサンプル。

## 参照

### アプリ開発・実行環境構築手順

- https://www.notion.so/Shopify-2025-28dbbd23715c805ca880ce301209e0a3

## 作業手順

### イニシャル（作業開始時に毎回実行）

1. 「product_env.sh.default」をコピーし、「product_env.sh」を作成　※プロジェクト初期化時のみ作業
  - export PRODUCT_CODE, PRODUCT_ENV, AWS_ACCOUNT_IDの値を設定
2. `$ source product_env.sh` を実行し、環境変数を定義
