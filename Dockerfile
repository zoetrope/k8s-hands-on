FROM quay.io/cybozu/golang:1.15-focal AS build-backend

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /work
COPY ./ .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o todo ./cmd/main.go


FROM node:14 AS build-frontend

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /work
COPY ./ .

RUN cd frontend && npm install && npm run build


FROM quay.io/cybozu/ubuntu:20.04 AS runtime

WORKDIR /

COPY --from=build-backend /work/todo /todo
COPY --from=build-frontend /work/frontend/dist /dist
USER 1000:1000
EXPOSE 8080

ENTRYPOINT ["/todo"]
