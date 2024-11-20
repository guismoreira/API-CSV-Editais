FROM eclipse-temurin:21-jdk

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN if [ -f requirements.txt ]; then python3 -m pip install -r requirements.txt; fi

# Usar imagem do Gradle diretamente
FROM gradle:7.2-jdk21 AS gradle-builder

COPY --from=gradle-builder /opt/gradle /opt/gradle

RUN gradle build

EXPOSE 8080

CMD ["java", "-jar", "build/libs/your-application.jar"]
