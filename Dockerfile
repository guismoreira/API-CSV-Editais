# Utiliza a imagem base do OpenJDK Temurin
FROM eclipse-temurin:21-jdk-focal AS build

# Instala o Python 3.12.7
RUN apt-get update && apt-get install -y \
    python3.12 \
    python3.12-distutils \
    python3.12-venv \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instala o Gradle
RUN curl -sSL https://get.gradle.org/distributions/gradle-7.6.2-bin.zip -o gradle.zip \
    && unzip gradle.zip -d /opt \
    && rm gradle.zip \
    && ln -s /opt/gradle-7.6.2/bin/gradle /usr/bin/gradle

# Configura o diretório de trabalho
WORKDIR /app

# Copia o código da aplicação para o container
COPY . /app

# Instala dependências Python
RUN python3.12 -m ensurepip --upgrade && \
    python3.12 -m pip install --no-cache --upgrade pip

# Se necessário, instale outras dependências Python
RUN python3.12 -m pip install -r requirements.txt

# Compila o projeto com Gradle
RUN gradle build

# Expõe a porta que a aplicação Spring usa (geralmente 8080)
EXPOSE 8080

# Comando para rodar a aplicação Spring
CMD ["gradle", "bootRun"]
