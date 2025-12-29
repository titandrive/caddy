# syntax=docker/dockerfile:1

ARG CADDY_VERSION=2.8.4

############################
# Build custom Caddy binary
############################
FROM caddy:${CADDY_VERSION}-builder AS builder

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    xcaddy build \
      --source github.com/caddyserver/caddy/v2@v${CADDY_VERSION} \
      --with   github.com/caddy-dns/cloudflare@latest \
      --with   github.com/lucaslorentz/caddy-docker-proxy/v2@v2.9.0


############################
# Final runtime image
############################
FROM caddy:${CADDY_VERSION}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
