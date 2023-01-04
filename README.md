# k8s-hands-on

## ディレクトリ構造

- manifests: 各種アプリケーションのマニフェスト
- todo: サンプルのTODOアプリ

## 事前準備

このハンズオンはLinux, WSL2(Ubuntu), macOS(Intel Chip)で動作します。
事前に下記のソフトウェアをインストールしておいてください。

- Goのインストール
    - https://golang.org/dl/
- Dockerのインストール
    - https://docs.docker.com/get-docker/
- make, curl, unzipなどのコマンドのインストール
    - macOSの場合は、Command Line Tools for Xcodeのインストールが必要です。
- aquaのインストール
    - https://aquaproj.github.io/docs/tutorial-basics/quick-start

## 利用方法

### ツールのセットアップ

このハンズオンで利用しているCLIツールは[aqau](https://aquaproj.github.io)で管理しています。
以下のコマンドでCLIツールのセットアップをおこなってください。

```console
aqua i -l
```

### Kubernetesクラスタの立ち上げ

kindでKubernetesクラスタを起動します。

```console
make launch-k8s
```

## アプリケーションのデプロイ

アプリケーションをデプロイします。

```console
make deploy-application
```

ApplicationがすべてSyncedになるまで待ちます。

```console
watch arogcd app list
```

数分待つとアプリケーションのデプロイが完了します。

## Grafanaの利用

ブラウザを開いて http://localhost:3000 にアクセスしてください。

下記のコマンドでパスワードを確認し、Grafanaの左下のメニューからSign Inをクリックし、Username: admin でログインします。

```console
make grafana-password
```

## Argo CDの利用

### Argo CDのWeb UIの利用

ブラウザを開いて http://localhost:8000 にアクセスしてください。

下記のコマンドでパスワードを確認し、Username: admin でログインします。

```console
make argocd-password
```

### argocd cliの使い方

コマンドラインでArgo CDにデプロイします。

```console
make login-argocd
```

ログインに成功すると、`argocd app list`などのコマンドが実行できるようになります。

## logcliの使い方

以下のようにコマンドを実行すると、CLIからログを確認することができます。

```console
logcli query '{namespace="argocd"}'
```

## Kubernetesクラスタの終了

ハンズオンを終えたいときや環境を最初から作り直したいときはKubernetesクラスタを削除できます。

```console
make shutdown-k8s
make stop-portforward
```
