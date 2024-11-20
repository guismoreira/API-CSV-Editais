# Usando uma imagem base do OpenJDK Temurin disponível
FROM eclipse-temurin:21-jdk-alpine AS build

# Instala o Python 3.12.7 e curl
RUN apk update && apk add --no-cache \
    python3 \
    python3-dev \
    py3-pip \
    curl \
    unzip \
    && rm -rf /var/cache/apk/*

# Instala o Gradle de forma robusta usando o gerenciador de pacotes Alpine
RUN apk add --no-cache gradle

# Configura o diretório de trabalho
WORKDIR /app

# Copia o código da aplicação para o container
COPY . /app

# Instala dependências Python (caso haja um requirements.txt)
RUN python3 -m ensurepip --upgrade && \
    python3 -m pip install --no-cache --upgrade pip

# Se necessário, instale outras dependências Python
RUN python3 -m pip install -r requirements.txt

# Compila o projeto com Gradle
RUN gradle build

# Expõe a porta que a aplicação Spring usa (geralmente 8080)
EXPOSE 8080

# Comando para rodar a aplicação Spring
CMD ["gradle", "bootRun"]
