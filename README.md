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

## モニタリング(VictoriaMetrics, Grafana, kube-state-metrics)

### モニタリングシステムのセットアップ

VictoriaMetrics, Grafana, kube-state-metricsをデプロイします。

```console
make deploy-monitoring
```

PodがすべてReadyになるまで待ちます。

```console
watch kubectl get pod -n monitoring-system
```

モニタリング対象のサンプルアプリケーションをデプロイします。

```console
make deploy-todo
```

### Grafanaの利用

ブラウザからGrafanaに接続できるようにPort Forwardします。

```console
make port-forward-grafana
```

ブラウザを開いて http://localhost:3000 にアクセスしてください。

下記のコマンドでパスワードを確認し、Grafanaの左下のメニューからSign Inをクリックし、Username: admin でログインします。

```console
make grafana-password
```

## 継続的デリバリー(ArgoCD)

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

ブラウザからArgoCDに接続できるようにPort Forwardします。

```console
make port-forward-argocd
```

ブラウザを開いて http://localhost:8080 にアクセスしてください。

下記のコマンドでパスワードを確認し、Username: admin でログインします。

```console
make argocd-password
```

ブラウザの画面から、argocd-configのSYNCをおこないます。
SYNCに成功すると、デプロイ可能なアプリケーションがいくつか表示されます。

続いて必要なアプリケーションのSYNCをおこないます。

- monitoring: モニタリングシステム
- loki: ログ収集システム
- todo: サンプルのWebアプリケーション
  
しばらく待ってStatusがHealthy/Syncedの状態になれば、デプロイ成功です。

## ロギング(loki)

### ロギングシステムのセットアップ

Loki, Grafanaをデプロイします。

```console
make deploy-loki
```

PodがすべてReadyになるまで待ちます。

```console
watch kubectl get pod -n loki
```

