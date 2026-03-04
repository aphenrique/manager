# ── Stage 1: Builder ──────────────────────────────────────────
FROM hexpm/elixir:1.19.4-erlang-28.3.3-alpine-3.22.3 AS builder   

RUN apk add --no-cache build-base git curl  

WORKDIR /app  

RUN mix local.hex --force && mix local.rebar --force  

ENV MIX_ENV=prod

# Instala dependências (camada cacheável)   
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod  

COPY config/config.exs config/prod.exs config/
RUN mix deps.compile

# Compila a aplicação (gera phoenix-colocated/manager no build path)
COPY priv priv
COPY lib lib
RUN mix compile

# Build de assets (Tailwind + esbuild)
COPY assets assets
RUN mix assets.setup
RUN mix assets.deploy

# Gera o release
COPY config/runtime.exs config/   
COPY rel rel  
RUN mix release 

# ── Stage 2: Runtime ──────────────────────────────────────────
FROM alpine:3.22 AS runtime   

RUN apk add --no-cache libstdc++ openssl ncurses-libs sqlite su-exec

WORKDIR /app

RUN addgroup -S app && adduser -S app -G app
RUN mkdir -p /app/data

COPY --from=builder /app/_build/prod/rel/manager ./
RUN chmod +x /app/bin/entrypoint.sh

ENV HOME=/app
ENV PHX_SERVER=true
ENV DATABASE_PATH=/app/data/manager.db

VOLUME ["/app/data"]
EXPOSE 4000

ENTRYPOINT ["/app/bin/entrypoint.sh"]
CMD ["/bin/sh", "-c", "/app/bin/manager eval 'Manager.Release.migrate()' && /app/bin/manager start"]
