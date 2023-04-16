# updated 2023-04-16
FROM alpine:3.17.3

LABEL maintainer="Chris Bräucker <github.com/chrisbraucker>"

RUN apk add --no-cache bash curl jq openssl

WORKDIR /app

ARG dehydrated_version="v0.7.1"
ADD https://raw.githubusercontent.com/lukas2511/dehydrated/${dehydrated_version}/dehydrated dehydrated

COPY . .

ENTRYPOINT ["bash", "dehydrated"]
