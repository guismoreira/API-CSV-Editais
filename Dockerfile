# Usando a imagem base do OpenJDK Temurin disponível
FROM eclipse-temurin:21-jdk-alpine AS build

# Atualiza o apk e instala o Python 3.12.7, curl, unzip e outras dependências necessárias
RUN apk update && apk add --no-cache \
    python3 \
    python3-dev \
    py3-pip \
    curl \
    unzip \
    bash \
    && rm -rf /var/cache/apk/*

# Certifica-se de que o pip está instalado corretamente
RUN python3 -m ensurepip --upgrade || true

# Atualiza o pip para a versão mais recente
RUN python3 -m pip install --upgrade pip

# Instala o Gradle
RUN apk add --no-cache gradle

# Configura o diretório de trabalho
WORKDIR /app

# Copia o código da aplicação para o container
COPY . /app

# Instala dependências Python (caso haja um requirements.txt)
RUN if [ -f requirements.txt ]; then python3 -m pip install -r requirements.txt; fi

# Compila o projeto com Gradle
RUN gradle build

# Expõe a porta que a aplicação Spring usa (geralmente 8080)
EXPOSE 8080

# Comando para rodar a aplicação Spring
CMD ["gradle", "bootRun"]

