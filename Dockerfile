FROM golang:1.13
ADD cmd/bash-exporter ./src/cmd/bash-exporter
WORKDIR /go/src/cmd/bash-exporter
RUN go get -d \
    && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bash-exporter .

FROM alpine:3.7
WORKDIR /root/
COPY --from=0 /go/src/cmd/bash-exporter/bash-exporter .
COPY ./examples/* /scripts/
RUN apk update && apk add bash coreutils curl jq \
    && curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.19.7/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    && apk add yq --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
CMD ["./bash-exporter"]
