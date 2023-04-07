# Pumaの設定ファイル
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count
port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { ENV['RACK_ENV'] || "production" }
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
preload_app!
plugin :tmp_restart
# nginxとRailsのデフォルトのサーバーであるpumaを連携
# 本番環境で稼働させるRailsでは、その前段にnginxを配置する構成を取ることが多い
# nginxとpumaをUNIXドメインソケット(プロセス間通信)と呼ばれる方式で通信させます
# これにより、pumaコマンドを使ってpumaを起動させると、Railsのディレクトリの/rails-deploy/tmp/socketsディレクトリ配下にpuma.sockという名前のファイルが作成されるようになります。このファイルを通じて、nginxとpumaが通信します。
app_root = File.expand_path("../..", __FILE__)  # ルートディレクトリの絶対パスを取得
bind "unix:#{app_root}/tmp/sockets/puma.sock"  # UNIXドメインソケットを作成する


# 【質問】
# このコードについて説明してください
# app_root = File.expand_path("../..", __FILE__)
# bind "unix:#{app_root}/tmp/sockets/puma.sock"
# 【回答】
# このコードは、Ruby on Railsアプリケーションの設定ファイルである config/puma.rb に書かれるものです。PumaというWebサーバーを起動するための設定を行います。
# app_root = File.expand_path("../..", __FILE__) は、設定ファイルから見たアプリケーションのルートディレクトリの絶対パス(= /rails-deploy)を取得しています。ここでは、File.expand_path メソッドを使用して、__FILE__ (= "puma.rb") からさかのぼって2つ上のディレクトリをアプリケーションのルートディレクトリとして取得しています。
# bind "unix:#{app_root}/tmp/sockets/puma.sock" は、Pumaが待ち受けるソケットのアドレス(= エンドポイント)を指定しています。ここでは、UNIXドメインソケットというタイプのソケットを指定しています。UNIXドメインソケットは、同じマシン内のプロセス間通信に利用されるソケットで、IPアドレスやポート番号を指定する必要がありません。アプリケーションサーバーとWebサーバーを同じマシンで動かす場合に、UNIXドメインソケットを使用することが多いです。
# 具体的には、app_root 変数に設定ファイルから見たアプリケーションのルートディレクトリの絶対パスが格納されます。そして、bind メソッドで、unix: スキームを使ってUNIXドメインソケットのアドレスを指定し、そのパスを app_root 変数を使用して設定しています。つまり、このコードはPumaをUNIXドメインソケットで起動し、ソケットのパスは「/rails-deploy/tmp/sockets/puma.sock」となるように設定しているということです。

# 【質問】
# ここで言う「ソケット」とはなんですか？
# 【回答】
# ソケット(socket)とは、コンピューターネットワークにおいて、通信を行うために必要な情報を集めた通信のエンドポイントです。ソケットは、IPアドレスとポート番号の組み合わせで表されます。通信する2つのプログラムは、それぞれソケットを作成し、相手方のソケットと接続して通信を行います。ソケットは、通信方式によって異なる種類があります。例えば、TCP/IPプロトコルでの通信には、ストリームソケットが使用されます。また、「UNIXドメインソケット」は、同一のマシン上でプロセス間通信を行うために使用されます。今回のコードでは、UNIXドメインソケットを使用しています。

# 【質問】
# ここで言う「エンドポイント」とはなんですか？
# 【回答】
# ここで言う「エンドポイント (endpoint)」とは、Webサーバーが提供するHTTPプロトコルにおいて、特定のリソースにアクセスするためのURLのことを指します。具体的には、Webサービスにおいて、ユーザーがアクセスすることができるAPIのURLを指すことが多いです。たとえば、https://example.com/api/v1/users というURLがユーザー情報を取得するAPIのエンドポイントであるといえます。

# 【質問】
# "../.." はどういう意味ですか？
# 【回答】
# "../.."は、現在のファイルが存在するディレクトリから見て、2つ上の親ディレクトリを指します。つまり、現在のファイルが存在するディレクトリの親の親ディレクトリを指します。

# 【質問】
# __FILE__ はどういう意味ですか？
# 【回答】
# __FILE__は、現在のファイル名を含むパスを表すマジックリテラル定数(Rubyで定義済みの特殊な定数)です。この定数は、ファイルのどこにでも配置されることができます。例えば、Rubyスクリプト内の__FILE__は、そのスクリプトのファイルパスに評価されます。この値をexpand_pathメソッドで使用することで、そのファイルの絶対パスを取得することができます。

# 【質問】
# File.expand_pathメソッドの第一引数と第二引数について説明してください
# 【回答】
# `File.expand_path` メソッドは、指定されたパス文字列を展開して正規化（絶対パスに変換する）するためのメソッドです。以下は `File.expand_path` メソッドのシグネチャです。
# ```ruby
# File.expand_path(path, base_dir = '')
# ```
# 第一引数の `path` は、展開したい相対パスまたは絶対パスの文字列を指定します。このパス文字列は、現在の作業ディレクトリやホームディレクトリからの相対パス、もしくは絶対パスで指定することができます。
# 第二引数の `base_dir` は、`path` の展開時に参照される基準となるディレクトリを指定します。`base_dir` に値を渡すことで、`path` が相対パスの場合でも、その相対パスの基準となるディレクトリを指定することができます。`base_dir` には、絶対パスまたは相対パスを指定することができます。省略した場合、カレントディレクトリが使用されます。
# たとえば、次のようなコードを考えます。
# ```ruby
# puts File.expand_path('../file.txt', '/Users/username/docs')
# # => /Users/username/file.txt
# ```
# このコードでは、第一引数に `../file.txt` という相対パスを指定しています。また、第二引数に `/Users/username/docs` という基準となるディレクトリを指定しています。この場合、`File.expand_path` メソッドは、`/Users/username/docs` を基準にして、`../file.txt` の相対パスを展開し、絶対パスの `/Users/username/file.txt` を返します。


# 【補足】コンテナ間でのpuma.sockの共有について
# ローカルのDocker環境では、appコンテナ(Railsやpumaのコンテナ)の/var/www/tmp/socketsディレクトリがwebコンテナと共有されています。
# そのため、異なるコンテナ間で、ひとつのファイルを使って通信が可能となっています。
# ```dicker-compose.yml
# web:
#   # 略
#   volumes:
#     # 略
#     - type: volume
#       source: puma-sock
#       target: /var/www/tmp/sockets

# app:
#   # 略
#   volumes:
#     # 略
#     - type: volume
#       source: puma-sock
#       target: /var/www/tmp/sockets
# ```
