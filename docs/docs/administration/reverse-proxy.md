# Reverse Proxy

Users can deploy a custom reverse proxy that forwards requests to Immich. This way, the reverse proxy can handle TLS termination, load balancing, or other advanced features. All reverse proxies between Immich and the user must forward all headers and set the `Host`, `X-Real-IP`, `X-Forwarded-Proto` and `X-Forwarded-For` headers to their appropriate values. Additionally, your reverse proxy should allow for big enough uploads. By following these practices, you ensure that all custom reverse proxies are fully compatible with Immich.

:::caution
Immich does not support being served on a sub-path such as `location /immich {`. It has to be served on the root path of a (sub)domain.
:::

:::danger Critical Configuration for Large File Uploads
**Reverse proxy timeouts are a common cause of upload failures for large video files.** If you experience upload failures for videos (especially > 1GB), check your reverse proxy timeout configuration:

- **Nginx**: Default timeouts are often 60 seconds. Videos taking longer than this will fail with no clear error message.
- **Traefik**: Default `respondingTimeouts` is 60 seconds, causing uploads to fail after 1 minute (Error Code 499).
- **Apache**: Requires explicit `timeout` parameter (default may be as low as 60 seconds).
- **Caddy**: Generally handles long uploads well by default, but can be affected by load balancer settings.

**Recommended minimum timeout: 600 seconds (10 minutes)** for typical use. Adjust higher if you regularly upload very large files over slow connections.
:::

:::info
If your reverse proxy uses the [Let's Encrypt](https://letsencrypt.org/) [http-01 challenge](https://letsencrypt.org/docs/challenge-types/#http-01-challenge), you may want to verify that the Immich well-known endpoint (`/.well-known/immich`) gets correctly routed to Immich, otherwise it will likely be routed elsewhere and the mobile app may run into connection issues.
:::

### Nginx example config

Below is an example config for nginx. Make sure to set `public_url` to the front-facing URL of your instance, and `backend_url` to the path of the Immich server.

```nginx
server {
    server_name <public_url>;

    # allow large file uploads - set to maximum expected file size
    client_max_body_size 50000M;

    # Set headers
    proxy_set_header Host              $host;
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # enable websockets: http://nginx.org/en/docs/http/websocket.html
    proxy_http_version 1.1;
    proxy_set_header   Upgrade    $http_upgrade;
    proxy_set_header   Connection "upgrade";
    proxy_redirect     off;

    # set timeout - critical for large file uploads
    # Increase these values if you have very large files or slow upload speeds
    proxy_read_timeout 600s;
    proxy_send_timeout 600s;
    send_timeout       600s;

    location / {
        proxy_pass http://<backend_url>:2283;
    }

    # useful when using Let's Encrypt http-01 challenge
    # location = /.well-known/immich {
    #     proxy_pass http://<backend_url>:2283;
    # }
}
```

### Caddy example config

As an alternative to nginx, you can also use [Caddy](https://caddyserver.com/) as a reverse proxy (with automatic HTTPS configuration). Below is an example config.

```caddy
immich.example.org {
    reverse_proxy http://<snip>:2283
    
    # Caddy handles timeouts well by default, but you can adjust if needed:
    # reverse_proxy http://<snip>:2283 {
    #     timeout 600s
    # }
}
```

### Apache example config

Below is an example config for Apache2 site configuration.

```ApacheConf
<VirtualHost *:80>
   ServerName <snip>
   ProxyRequests Off
   # CRITICAL: set timeout in seconds - default is often too low for large uploads
   # Increase beyond 600 if you have very large files or slow connections
   ProxyPass / http://127.0.0.1:2283/ timeout=600 upgrade=websocket
   ProxyPassReverse / http://127.0.0.1:2283/
   ProxyPreserveHost On
</VirtualHost>
```

### Traefik Proxy example config

The example below is for Traefik version 3.

:::danger
**Critical:** The default `respondingTimeouts` in Traefik is 60 seconds, which causes video uploads to fail after 1 minute with **Error Code 499**. You **must** increase these timeouts to support large file uploads.
:::

The most important step is to increase the `respondingTimeouts` of the entrypoint used by Immich. In this example, the entrypoint `websecure` for port `443` is configured with 10-minute timeouts, which is sufficient for most use cases. Increase further if you have very large files or slow upload speeds.

`traefik.yaml`

```yaml
[...]
entryPoints:
  websecure:
    address: :443
    # CRITICAL: this section must be added to support large file uploads
    transport:
      respondingTimeouts:
        readTimeout: 600s
        idleTimeout: 600s
        writeTimeout: 600s
```

The second part is in the `docker-compose.yml` file where immich is in. Add the Traefik specific labels like in the example.

`docker-compose.yml`

```yaml
services:
  immich-server:
    [...]
    labels:
      traefik.enable: true
      # increase readingTimeouts for the entrypoint used here
      traefik.http.routers.immich.entrypoints: websecure
      traefik.http.routers.immich.rule: Host(`immich.your-domain.com`)
      traefik.http.services.immich.loadbalancer.server.port: 2283
```

Keep in mind, that Traefik needs to communicate with the network where immich is in, usually done
by adding the Traefik network to the `immich-server`.

### Cloudflare Tunnel

:::danger Upload Size Limits
**Cloudflare has strict upload size limits that CANNOT be bypassed:**

- **Free plan**: 100 MB maximum upload size
- **Paid plans**: Up to 500 MB (varies by plan)

**These limits apply to the entire request body, meaning:**

- You cannot upload videos larger than the limit
- Large photo uploads may fail
- The 413 "Payload Too Large" error comes from Cloudflare, not your server

**Mobile App Behavior:** The Immich mobile app automatically filters out files >= 99MB during backup to prevent upload failures when using Cloudflare Tunnel or other size-restricted reverse proxies. Large files are removed from the backup queue and will not appear in the "Remainder" count, effectively excluding them from backup. This multi-layer filtering approach ensures:

1. Large files are filtered from backup candidates immediately after database retrieval
2. Existing queued large files are removed during queue refresh
3. A final safety check prevents any large files from being uploaded

Filtered files are logged with their sizes for monitoring purposes.

**Solutions:**

1. **Use direct connection for uploads**: Configure your mobile app to upload via local IP (192.168.x.x) when on home WiFi, and use Cloudflare tunnel only for remote viewing/downloading
2. **Upgrade to Cloudflare Business plan** ($200+/month) for larger limits (up to 500 MB)
3. **Use a different reverse proxy solution** (Tailscale, WireGuard, or direct port forwarding with Let's Encrypt)

**Note:** Immich server itself has no upload size limits - this is purely a Cloudflare restriction.
:::

If you choose to use Cloudflare Tunnel despite the upload limitations, here's the configuration:

`config.yml` (Cloudflare Tunnel configuration)

```yaml
tunnel: <tunnel-id>
credentials-file: /path/to/credentials.json

ingress:
  - hostname: immich.your-domain.com
    service: http://localhost:2283
    originRequest:
      # These don't bypass Cloudflare's upload limits but help with timeout issues
      noTLSVerify: false
      connectTimeout: 30s
      # Cloudflare tunnel doesn't expose timeout settings that affect upload size limits
      # The limits are enforced at Cloudflare's edge and cannot be configured here
  - service: http_status:404
```

**Important:** Even with proper tunnel configuration, uploads larger than your Cloudflare plan's limit will fail with HTTP 413 errors. Consider using split-tunnel approach where uploads go directly to your server.
