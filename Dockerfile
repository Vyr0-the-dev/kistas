FROM node:20-slim

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    neovim \
    && rm -rf /var/lib/apt/lists/*

# Gemini CLI
RUN npm install -g @google/gemini-cli

WORKDIR /app

CMD ["bash"]
