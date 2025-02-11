#【スクリプト名】ログ監視・フィルタリングスクリプト

##概要
このスクリプトは、特定のアプリケーションおよび/var/log/messagesのエラーログを抽出し、指定されたディレクトリに保存するものです。
（不要な空ログの削除や、エラー時のハンドリングも行う）

##使用方法
bash
①bash△check_log.sh　#実行時に引数なし
②bash△check_log_call.sh△data_list.txt #引数で関数を指定して実行するパターンを制限する

引数の説明
 data_list.txtの中身は以下のようになっており、そこに記載されている関数パターンのみ実行する。
  APACHE_LOG
  MESSAGES_LOG

 スクリプト内での関数の呼び出しは以下
  #各ログファイルの処理(関数を呼び出す)
  while read -r line; do
   case "$line" in
    "APACHE_LOG")
     filter_logs "${APACHE_LOG}" "apache"
     ;;
    "NGINX_LOG")
     filter_logs "${NGINX_LOG}" "nginx"
     ;;
    "MYSQL_LOG")
     filter_logs "${MYSQL_LOG}" "mysql"
     ;;
    "MESSAGES_LOG")
     filter_logs "${MESSAGES_LOG}" "messages"
     ;;
    *)
     echo "エラー: 無効なデータ $line が含まれています。" >&2
     ;;
   esac
  done < "$DATA_LIST"
   
##出力結果
実行すると、以下のようなログファイルが/tmp/log_filter/に作成されます：
/tmp/log_filter/apache_error_20250210-1200.log
/tmp/log_filter/nginx_error_20250210-1200.log
/tmp/log_filter/mysql_error_20250210-1200.log
※エラーログがない場合、空ログは自動削除する

##エラーハンドリング
①ログファイルが存在しない場合
エラー: /var/log/httpd/error_log が存在しません。

②無効なキーワードを渡した場合
エラー: 無効なデータ unknown_service が含まれています。

##応用
①関数のパターンを追加したり、関数リスト(data_list.txt )の記載を修正することで他ファイルからの抽出も可

②cronに登録して定期実行にする
*/5 * * * * /bin/bash /tmp/test/check_log.sh >> /tmp/log_filter/cron_log.txt 2>&1

