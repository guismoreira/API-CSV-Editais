FROM eclipse-temurin:21-jdk AS base

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /my-project

COPY . /my-project

RUN python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install requests beautifulsoup4 pandas

RUN chmod +x ./gradlew && ./gradlew clean build

ENV ENVIRONMENT=local

EXPOSE 8080

CMD ["java", "-jar", "build/libs/concurso-0.0.1-SNAPSHOT.jar"]
