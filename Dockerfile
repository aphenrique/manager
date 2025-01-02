# Use a imagem base para Elixir e Phoenix
FROM ubuntu

# Defina o diretório de trabalho da aplicação
WORKDIR /opt/app

# Atualize o sistema e instale as dependências
RUN apt update -y && \
    apt upgrade -y  && \
    apt install -y  elixir git

# Instale as dependências do Elixir
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new

# Copie o restante do código da aplicação para dentro do contêiner
COPY . .

RUN mix deps.get

# Compile o código da aplicação
# RUN mix deps.compile

# Exponha a porta que o Phoenix irá usar
EXPOSE 4000

# Comando para iniciar o servidor Phoenix
CMD ["mix", "phx.server"]
