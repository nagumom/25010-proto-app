#!/bin/bash

# 環境変数に必要な値を読み込みます
# 【注意】EC2でShopifyアプリを起動する前に実行してください
# 【注意】aws/scripts配下の「product_env.sh」を実行した後に実行してください

if [ -z ${PRODUCT_CODE} ] || [ -z ${PRODUCT_ENV} ]; then
    echo "PRODUCT_CODE, PRODUCT_ENV is not set."
    exit;
fi

# app
APP_SECRETS_JSON=$(aws secretsmanager get-secret-value --secret-id ${PRODUCT_SECRETS_APP} --region ${AWS_REGION} --query SecretString --output text)

export SHOPIFY_API_KEY=$(echo ${APP_SECRETS_JSON} | jq -r .SHOPIFY_API_KEY)
export SHOPIFY_API_SECRET=$(echo ${APP_SECRETS_JSON} | jq -r .SHOPIFY_API_SECRET)
export SCOPES=$(echo ${APP_SECRETS_JSON} | jq -r .SCOPES)
export SHOPIFY_APP_URL=$(echo ${APP_SECRETS_JSON} | jq -r .SHOPIFY_APP_URL)

# db
#export DATABASE_URL="mysql://[ユーザ名]:[パスワード]@[エンドポイント]:[ポート番号]/[データベース名]"
DB_SECRETS_JSON=$(aws secretsmanager get-secret-value --secret-id ${PRODUCT_SECRETS_DB} --region ${AWS_REGION} --query SecretString --output text)

export DB_USERNAME=$(echo ${DB_SECRETS_JSON} | jq -r .username)
export DB_PASSWORD=$(echo ${DB_SECRETS_JSON} | jq -r .password)
export DB_ENGINE=$(echo ${DB_SECRETS_JSON} | jq -r .engine)
export DB_HOST=$(echo ${DB_SECRETS_JSON} | jq -r .host)
export DB_PORT=$(echo ${DB_SECRETS_JSON} | jq -r .port)
export DB_DBNAME=$(echo ${DB_SECRETS_JSON} | jq -r .dbname)

export PRISMA_DATABASE_URL="${DB_ENGINE}://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_DBNAME}"
