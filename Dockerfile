FROM eclipse-temurin:21-jdk AS base

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://services.gradle.org/distributions/gradle-7.6-bin.zip -P /tmp \
    && unzip /tmp/gradle-7.6-bin.zip -d /opt \
    && ln -s /opt/gradle-7.6/bin/gradle /usr/bin/gradle

WORKDIR /my-project

COPY . /my-project

RUN python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install requests beautifulsoup4 pandas

RUN chmod +x gradle && gradle clean build

ENV ENVIRONMENT=PROD

EXPOSE 8080

CMD ["java", "-jar", "build/libs/app.jar"]
