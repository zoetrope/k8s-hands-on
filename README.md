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

## モニタリング(VictoriaMetrics)について学ぶ

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
kubectl -n grafana port-forward svc/grafana-service 3000:3000
```

ブラウザを開いて http://localhost:3000 にアクセスしてください。

下記のコマンドでパスワードを確認し、Grafanaの左下のメニューからSign Inをクリックし、Username: admin でログインします。

```console
make grafana-password
```

## 継続的デリバリー(ArgoCD)について学ぶ

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
kubectl -n argocd port-forward svc/argocd-server 8080:80
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
