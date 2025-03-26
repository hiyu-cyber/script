#!/bin/bash

#監査対象ログファイル
LOG_FILE="/var/log/syslog"
#検出対象のエラーパターン
ALERT_PATTERN="error|failed|critical"
#アラート送信先
ALERT_EMAIL="admin@example.com"
#一時ログファイル
TMP_FILE="/tmp/alert.log"
#多重起動防止用
LOCK_FILE="/tmp/alert_script.lock"

 #trapを使ってスクリプト終了時にロックファイル削除
 trap 'rm -f "${LOCK_FILE}"; exit 0' INT TERM EXIT
 
 #スクリプト多重起動防止
 if [[ -e "${LOCK_FILE}" ]];then
  echo "スクリプトがすでに実行中です。"　>&2
  exit 1
 fi
 touch "${LOCK_FILE}"
 
 #一時ログファイル作成
 if [ ! -e "$TMP_FILE" ]; then
  touch "$TMP_FILE"
 fi
 
 #アラート通知関数(メール+ログ記録)
 send_alert() {
 	local messages="$1"
 	echo "【ALEAT】$messages" | mailx -s "システムアラート発生" "$ALERT_EMAIL"
 	logger -p user.err "【ALEAT】$messages" #ログに記録
 }
 
 #メイン監視ループ
 monitor_logs() {
 	cat "$LOG_FILE" | while read -r line; do
 	 if echo "$line" | grep -Ei "$ALERT_PATTERN"; then
 	  #エラーメッセージ抽出(日時、エラーレベル、メッセージ部分)
 	  error_message=$(echo "$line" | awk '{print $1, $2, $3, substr($0, index($0,$4))}')
 	  send_alert "$error_message"
 	  echo "$error_message" >> "$TMP_FILE"
 	 fi
 	done
 }
 
 #実行
 monitor_logs