FROM eclipse-temurin:21-jdk AS base

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

FROM gradle:7.2-jdk21-alpine AS gradle-builder

WORKDIR /app

COPY . /app

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install requests beautifulsoup4 pandas

RUN gradle build

EXPOSE 8080

CMD ["java", "-jar", "build/libs/your-application.jar"]
