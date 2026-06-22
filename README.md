# llama-swap WoL Proxy

A containerized wrapper for [wol-proxy](https://github.com/mostlygeek/llama-swap/tree/main/cmd/wol-proxy) from [llama-swap](https://github.com/mostlygeek/llama-swap).

## Quick Start

Configure your environment:
```bash
cp .env.example .env
```
> [!TIP]
> Edit `.env` with your `LS_WOL_MAC` and `LS_WOL_UPSTREAM` settings.

### Docker Compose
```bash
docker compose up -d
```

### Docker Run
> [!IMPORTANT]
> --network host is required for L2 WoL broadcasts.

```bash
docker run --network host --env-file .env ghcr.io/nuttysalmon/ls-wol-proxy-docker:latest
```

## Configuration

- **LS_WOL_MAC** — Example: `BA:DC:0F:FE:E0:00`
- **LS_WOL_UPSTREAM** — Example: `http://upstream:8080`
- **LS_WOL_LISTEN** — Default: `8080`
- **LS_WOL_LOG** — Default: `info`
- **LS_WOL_TIMEOUT** — Default: `60`

## Security

- **Minimal Attack Surface**: Built on a lightweight Alpine image.
- **Privilege Dropping**: Runs as a non-root user via `su-exec`.
- **Hardened Runtime**: Uses a read-only filesystem and `no-new-privileges`.
- **Granular Capabilities**: Only grants necessary capabilities (`NET_ADMIN`, `SETUID`, `SETGID`).

## Self-Signed Certificates

To trust a self-signed upstream, mount the certificate into the container:

- **Docker Compose**: Add to the `volumes` section in `docker-compose.yaml`.
- **Docker Run**: `-v /path/to/cert.crt:/usr/local/share/ca-certificates/upstream.crt`

> [!IMPORTANT]
> Ensure the certificate's Subject Alternative Name (SAN) matches the upstream hostname or IP.

## Verification

Test the proxy with `curl`:
```bash
curl http://localhost:8080/v1/models
```

Check the logs:
```bash
docker compose logs -f
```
