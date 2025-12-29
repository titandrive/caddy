FROM caddy:2.8.4-builder AS builder

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    xcaddy build v2.8.4 \
      --with github.com/caddy-dns/cloudflare@latest \
      --with github.com/lucaslorentz/caddy-docker-proxy/v2@v2.9.0

FROM caddy:2.8.4

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
