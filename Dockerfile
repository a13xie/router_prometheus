FROM alpine:edge AS builder

ADD . /build
WORKDIR /build

RUN apk add python3 py3-build

RUN python3 -m build --wheel

FROM alpine:edge AS runner
LABEL org.opencontainers.image.source https://github.com/satcom886/router_prometheus

RUN mkdir /config

RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/testing/ | tee -a /etc/apk/repositories
RUN apk add curl python3 py3-yaml py3-prometheus-client fabric

COPY --from=builder /build/dist /dist
RUN apk add py3-pip && pip3 install /dist/* && apk del -r py3-pip && rm -r /dist

# The port instide the container must remain set to 8080 in order for this healthcheck to work
HEALTHCHECK --interval=60s --timeout=5s CMD curl -f http://localhost:8080/ || exit 1
CMD ["python3", "-u", "-m", "router_prometheus"]
