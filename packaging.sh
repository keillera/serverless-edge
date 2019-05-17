#!/usr/bin/env bash

docker build --tag amazonlinux:node .

# 初期化
rm -rf ./dist
rm -rf ./tmp
mkdir ./dist ./tmp
cp -r ./src/images/resize/origin_response ./tmp/
cp -r ./src/images/resize/viewer_request ./tmp/
cp -r ./src/send_token/crypto ./tmp/

# 環境変数設定。Lambda@edge は環境変数が使えないため、sed で直接書き換える
SSM_BUCKET_NAME=`aws ssm get-parameter --name ${ALIS_APP_ID}ssmDistS3BucketName --query "Parameter.Value" --output text`
sed -i '' "s/<DIST_S3_BUCKET_NAME>/${SSM_BUCKET_NAME}/g" tmp/origin_response/index.js

# ライブラリ取得
docker run --rm --volume ${PWD}/tmp/origin_response:/build amazonlinux:node /bin/bash -c "source ~/.bashrc; npm init -f -y; npm install sharp --save; npm install querystring --save; npm install --only=prod"
docker run --rm --volume ${PWD}/tmp/viewer_request:/build amazonlinux:node /bin/bash -c "source ~/.bashrc; npm init -f -y; npm install querystring --save; npm install --only=prod"
docker run --rm --volume ${PWD}/tmp/crypto:/build amazonlinux:node /bin/bash -c "source ~/.bashrc; npm init -f -y; npm install querystring --save; npm install --only=prod"

# zip 作成
mkdir -p dist && cd tmp/origin_response && zip -FS -q -r ../../dist/origin_response.zip * && cd ../..
mkdir -p dist && cd tmp/viewer_request && zip -FS -q -r ../../dist/viewer_request.zip * && cd ../..
mkdir -p dist && cd tmp/crypto && zip -FS -q -r ../../dist/crypto.zip * && cd ../..
