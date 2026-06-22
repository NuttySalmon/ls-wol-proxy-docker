# Llama-Swap Wol-Proxy Dockerfile

# ============================================================
# Stage 1: Clone and build llama-swap from source
# ============================================================
FROM golang:1.23-alpine AS builder

WORKDIR /src

RUN apk add --no-cache git binutils

# Use tmpfs for git cache (don't persist sensitive data)
RUN git config --global --add safe.directory /src

RUN git clone --no-checkout https://github.com/mostlygeek/llama-swap . && \
    git checkout b429349e8a3f58393bb91414e1ebb0c7258db6b2

ARG TARGETOS=linux
ARG TARGETARCH=amd64

RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -o /src/wol-proxy ./cmd/wol-proxy/ && \
    strip /src/wol-proxy && \
    chmod +x /src/wol-proxy

# ============================================================
# Stage 2: Runtime — Alpine for shell entrypoint
# ============================================================
FROM alpine:3.21 AS ls-wol-proxy

# Install ca-certificates and su-exec (for privilege dropping)
RUN apk add --no-cache ca-certificates su-exec && \
    adduser -D -u 1000 alpine

# Copy the wol-proxy binary
COPY --from=builder /src/wol-proxy /ls-wol-proxy

# Copy the HTML loading page from the cloned repo
COPY --from=builder /src/cmd/wol-proxy/index.html /index.html

# Copy the entrypoint script with correct permissions
COPY --chmod=0755 docker-entrypoint.sh /docker-entrypoint.sh

# Note: We no longer use USER alpine here. 
# The entrypoint will handle dropping privileges.

ENTRYPOINT ["/docker-entrypoint.sh"]
