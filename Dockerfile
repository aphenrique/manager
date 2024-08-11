FROM elixir

RUN apt update \
    && apt install -y inotify-tools

RUN mix do local.hex --force, local.rebar --force

WORKDIR /app

ENV MIX_ENV=dev

COPY mix.exs .
COPY mix.lock .
COPY config .

RUN mix deps.get --only $MIX_ENV

COPY . .

# EXPOSE 4000

# CMD ["mix", "phx.server"]
