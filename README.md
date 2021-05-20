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

ArgoCDの設定を適用します。

```console
kubectl -n argocd apply -f manifests/argocd-config/argocd-config.yaml
```

### ArgoCDの利用

```console
kubectl -n argocd port-forward svc/argocd-server 8080:80
```

```console
make argocd-password
```

```console
argocd login localhost:8080
```

```console
./bin/argocd app sync argocd-config
```

### Grafanaの利用

```console
kubectl -n grafana port-forward svc/grafana-service 3000:3000
```

```console
make grafana-password
```

### logcliの利用

```console
kubectl -n loki port-forward svc/loki 3100:3100
```

```console
logcli query '{namespace="kube-system"}'
```
