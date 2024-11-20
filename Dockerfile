FROM eclipse-temurin:21-jdk AS base

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /my-project
CMD ["./gradlew", "clean", "bootJar"]
COPY build/libs/*.jar app.jar

WORKDIR /app

COPY . /app

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install requests beautifulsoup4 pandas

RUN gradle build

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
