# Caddy - with Cloudflare DNS & Docker Proxy

## About
This is a custom [Caddy](https://github.com/caddyserver/caddy) build I made for my own needs, inspired by [Custom Caddy Builds](https://github.com/serfriz/caddy-custom-builds). I wanted to make this available publicly as this specific combbination is not currently provided. This build includes the following modules:
- [Cloudflare DNS](https://github.com/caddy-dns/cloudflare): Provides automatic DNS-01 validation via Cloudflare API
- [Docker Proxy](https://github.com/lucaslorentz/caddy-docker-proxy): Enables Caddy to be used for Docker containers via labels. 


## How to use
This version of Caddy runs in hybrid mode and requires a minimal Caddyfile to function. You can declare your subdomains via either the Caddyfile or using docker labels. I primarily use docker labels but rely on Caddyfile declarations for a few of my containers that require more complicated configuration. Below are basic instructions to get up and running. Please refer to the modules' documentation (linked above) for more indepth information. To get started, you will need to setup a Cloudflare API [token](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/) and create a wildcard (*) A Name entry for your domain. Caddy will take care of the rest from there. 

The installation requires the following two files to function. The below installation is for Unraid but can be modified for your server configuraiton.
- /Caddy/caddy.yml
- /Caddy/Caddyfile

### caddy.yml
```
services:
  caddy:
    image: ghcr.io/titandrive/caddy:latest
    container_name: caddy
    restart: unless-stopped
    environment:
      - CLOUDFLARE_API_TOKEN=[INSERT_TOKEN_HERE]
      - CADDY_DOCKER_CADDYFILE_PATH=/etc/caddy/Caddyfile
    networks:
      - dockernet
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /mnt/user/appdata/caddy/Caddyfile:/etc/caddy/Caddyfile
      - /mnt/user/appdata/caddy/data:/data
      - /mnt/user/appdata/caddy/config:/config
      - /var/run/docker.sock:/var/run/docker.sock #docker access for docker proxy
networks:
  dockernet:
    external: true
```

### Caddyfile
```
# ─────────────────────────────
#Catch-All - REQUIRED
# ─────────────────────────────
*.domain.com {
	respond "This subdomain hasn't been configured yet"
}

# ─────────────────────────────
# Example Domain - OPTIONAL
# ─────────────────────────────
homepage.domain.com {
	reverse_proxy homepage:3000
}
```
Once Caddy is running, you can either create a subdomain via the Cadddyfile (see the homepage example above) or you can do so using Docker labels. Below is an example on how to do that. 

### BentoPDF.yml
```
services:
  bentopdf:
    image: bentopdf/bentopdf-simple:latest
    container_name: bentopdf
    restart: unless-stopped
    networks:
      - dockernet
    labels:
      caddy: bentopdf.domain.com
      caddy.reverse_proxy: "{{upstreams 8080}}" #configure your desired subdomain and declare the container port
    
networks:
  dockernet:
    external: true
```

#### License
Software under [GPL-3.0](https://github.com/serfriz/caddy-custom-builds/blob/main/LICENSE) ensures users' freedom to use, modify, and distribute it while keeping the source code accessible. It promotes transparency, collaboration, and knowledge sharing. Users agree to comply with the GPL-3.0 license terms and provide the same freedom to others.
