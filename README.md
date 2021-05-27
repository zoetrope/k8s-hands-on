# k8s-hands-on

## ディレクトリ構造

- manifests: 各種アプリケーションのマニフェスト
- todo: サンプルのTODOアプリ

## 事前準備

- Goのインストール
- Dockerのインストール
- make, curl, unzipなどのコマンドのインストール

## 利用方法

### ツールのセットアップ

```console
make setup
```

`bin`ディレクトリにツールがダウンロードされるので、必要に応じてPATHを通してください。

```console
PATH=$(pwd)/bin:$PATH
```

### Kubernetesクラスタの立ち上げ

kindでKubernetesクラスタを起動します。

```console
make launch-k8s
```

PodがすべてReadyになるまで待ちます。

```console
watch kubectl get pod -n kube-system
```

### ArgoCDのセットアップ

ArgoCDをデプロイします。

```console
make deploy-argocd
```

PodがすべてReadyになるまで待ちます。

```console
watch kubectl get pod -n argocd
```

### ArgoCDの利用

ブラウザを開いて http://localhost/argocd にアクセスしてください。

下記のコマンドでパスワードを確認し、Username: admin でログインします。

```console
make argocd-password
```

ブラウザの画面から、argocd-configのSYNCをおこないます。
SYNCに成功すると、デプロイ可能なアプリケーションがいくつか表示されます。

続いて必要なアプリケーションのSYNCをおこないます。

- contour: L7ロードバランサー
- monitoring: モニタリングシステム
- loki: ログ収集システム
- todo: サンプルのWebアプリケーション
  
しばらく待ってStatusがHealthy/Syncedの状態になれば、デプロイ成功です。

### Grafanaの利用

ブラウザを開いて http://localhost/grafana にアクセスしてください。

下記のコマンドでパスワードを確認し、Grafanaの左下のメニューからSign Inをクリックし、Username: admin でログインします。

```console
make grafana-password
```
