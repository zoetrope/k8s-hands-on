FROM quay.io/cybozu/golang:1.21-focal AS build-server

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /work
COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download

COPY cmd/ cmd/
COPY server/ server/

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o todo ./cmd/main.go

FROM node:21 AS build-ui

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /work
COPY ui/package.json ui/package.json
COPY ui/package-lock.json ui/package-lock.json

RUN cd ui && npm ci

COPY ui/ ui/
RUN cd ui && npm run build

FROM quay.io/cybozu/ubuntu:24.04 AS runtime

LABEL org.opencontainers.image.source https://github.com/zoetrope/k8s-hands-on

WORKDIR /

COPY --from=build-server /work/todo /todo
COPY --from=build-ui /work/ui/dist /dist
USER 1000:1000
EXPOSE 8080

ENTRYPOINT ["/todo"]
