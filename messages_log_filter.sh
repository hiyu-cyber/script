#! /bin/bash

#/var/log/messagesからエラーログ抽出

KEY_WORD="$@" #すべての引数を取得（複数対応）

TIMESTAMP=$(date "+%Y%m%d-%H%M")
LOGFILE="/var/log/messages"
OUTPUT_DIR="/tmp/test"

#出力ディレクトリの作成（存在しない場合のみ）
mkdir -p "${OUTPUT_DIR}"

#ログファイルの存在確認
if [ ! -f "${LOGFILE}" ];then
 echo "エラー: ${LOGFILE} が存在しません" >&2
 exit 1
fi 

#検索対象キーワード
for i in "$@"; do
    OUTPUT_FILE="${OUTPUT_DIR}"/${i}_${TIMESTAMP}.log
    
    #ファイルを初期化(これで空ファイルが発生しないようにする)
    > "${OUTPUT_FILE}"
    
    grep "${i}" "${LOGFILE}" >> "${OUTPUT_FILE}"
    
    if [ ! -s "${OUTPUT_FILE}" ];then
     rm -f "${OUTPUT_FILE}"
     echo "ログが存在しません: ${OUTPUT_FILE}"
    else
     echo "ログ抽出完了: ${OUTPUT_FILE}"
    fi
done

