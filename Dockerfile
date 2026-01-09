FROM node:20-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    openjdk-17-jdk \
    python3 \
    python3-pip \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Gemini CLI
RUN npm install -g @google/gemini-cli

ENV FLUTTER_ROOT=/flutter \
    ANDROID_SDK_ROOT=/android-sdk \
    ANDROID_HOME=/android-sdk \
    PATH="/flutter/bin:/android-sdk/cmdline-tools/latest/bin:/android-sdk/platform-tools:/android-sdk/emulator:/android-sdk/tools/bin:${PATH}"

WORKDIR /app

CMD ["bash"]
