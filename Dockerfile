FROM ubuntu:24.04

ARG RUNNER_VERSION=2.323.0

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    TZ="Europe/Prague" \
    UBUNTU_VERSION_NAME=noble

RUN apt-get update && apt-get install -y curl jq locales libicu-dev && locale-gen en_US.UTF-8

RUN mkdir -p /actions-runner
WORKDIR /actions-runner

RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN ./bin/installdependencies.sh

COPY entrypoint.sh /actions-runner/entrypoint.sh
RUN chmod +x /actions-runner/entrypoint.sh
ENTRYPOINT ["/actions-runner/entrypoint.sh"]

