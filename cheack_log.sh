#!/bin/bash

#特定アプリ(Apache, Nginx, MySQL)のエラーログ抽出スクリプト
# - Apache: /var/log/httpd/error_log
# - Nginx: /var/log/nginx/error.log
# - MySQL: /var/log/mysql/error.log
# - フィルタリングするキーワードはスクリプト内で定義

TIMESTAMP=$(date "+%Y%m%d-%H%M")
OUTPUT_DIR="/tmp/log_filter"
mkdir -p "${OUTPUT_DIR}"

#ログ保存先
APACHE_LOG="/var/log/httpd/error_log"
NGINX_LOG="/var/log/nginx/error.log"
MYSQL_LOG="/var/log/mysql/error.log"

#検索対象キーワード（必要に応じて変更、追加可）
FILTER_KEYWORD=("error" "critical" "fail" "denied")

#ログファイル存在確認
check_log_file() {
 if [ ! -f "$1" ]; then
  echo "エラー: $1 が存在しません" >&2
  return 1
 fi
 return 0
}

#ログフィルタリング関数
filter_logs() {
 local log_file=$1
 local log_name=$2
 local output_file="${OUTPUT_DIR}/${log_name}_${TIMESTAMP}.log"
 
 #ログファイルが存在しなければスキップ
 check_log_file "${log_file}" || return
 
 #ファイルを初期化
 > "${output_file}"
 
 for keyword in "${FILTER_KEYWORD[@]}"; do
  grep -i "${keyword}" "${log_file}" >> "${output_file}"
 done
 
 #ログが抽出されなければ削除(0バイトだった場合)
 if [ ! -s "${output_file}" ]; then
  rm -f "${output_file}"
  echo "ログが存在しません: ${output_file}"
 else
  echo "ログ抽出完了: ${output_file}"
 fi
}

#各ログファイルの処理
filter_logs "${APACHE_LOG}" "apache" 
filter_logs "${NGINX_LOG}" "nginx"
filter_logs "${MYSQL_LOG}" "mysql"