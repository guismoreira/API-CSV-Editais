FROM ubuntu:20.04 AS build

RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    python3 \
    python3-pip \
    curl \
    unzip \
    bash \
    gradle \
    && apt-get clean

RUN python3 --version && python3 -m pip --version

RUN python3 -m pip install --upgrade pip

WORKDIR /app

COPY . /app

RUN if [ -f requirements.txt ]; then python3 -m pip install -r requirements.txt; fi

RUN gradle build

EXPOSE 8080

CMD ["gradle", "bootRun"]
