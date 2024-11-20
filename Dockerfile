FROM eclipse-temurin:21-jdk AS base

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install requests beautifulsoup4 pandas

RUN curl -sSL https://services.gradle.org/distributions/gradle-7.2-bin.zip -o gradle.zip && \
    unzip gradle.zip -d /opt && \
    rm gradle.zip && \
    ln -s /opt/gradle-7.2/bin/gradle /usr/bin/gradle

RUN ./gradlew clean bootJar

EXPOSE 8080

CMD ["java", "-jar", "build/libs/app.jar"]
