#! /bin/bash

#/var/log/messagesからエラーログ抽出（Cron対応）

#検索キーワードをスクリプト内で指定
 KEYWORDS=("error" "systemd")

TIMESTAMP=$(date "+%Y%m%d-%H%M")
LOGFILE="/var/log/messages"
OUTPUT_DIR="/tmp/test"

#出力ディレクトリの作成（存在しない場合のみ）
mkdir -p "${OUTPUT_DIR}"

#ログファイルの存在確認
if [ ! -f "${LOGFILE}" ]; then
 echo "エラー: ${LOGFILE} が存在しません" >&2
 exit 1
fi 

#検索対象キーワード
for i in "${KEYWORDS[@]}"; do
    OUTPUT_FILE="${OUTPUT_DIR}"/${i}_${TIMESTAMP}.log
    
    #ファイルを初期化(これで空ファイルが発生しないようにする)
    > "${OUTPUT_FILE}"
    
    grep "${i}" "${LOGFILE}" >> "${OUTPUT_FILE}"
    
    if [ ! -s "${OUTPUT_FILE}" ]; then
     rm -f "${OUTPUT_FILE}"
     echo "ログが存在しません: ${OUTPUT_FILE}"
    else
     echo "ログ抽出完了: ${OUTPUT_FILE}"
    fi
done
