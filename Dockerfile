FROM eclipse-temurin:21-jdk-focal

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://get.gradle.org/distributions/gradle-7.6.2-bin.zip -o gradle.zip && \
    unzip gradle.zip -d /opt && \
    rm gradle.zip && \
    ln -s /opt/gradle-7.6.2/bin/gradle /usr/bin/gradle

WORKDIR /app

COPY . /app

RUN if [ -f requirements.txt ]; then python3 -m pip install -r requirements.txt; fi

RUN gradle build

EXPOSE 8080

CMD ["java", "-jar", "build/libs/your-application.jar"]
