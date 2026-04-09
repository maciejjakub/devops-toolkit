# Claude Code + LiteLLM proxy — isolated agentic environment (isoagenv)
# Base: python:3.12-slim ships Python + pip; we add curl on top.
# The native Claude Code installer requires no Node.js or npm.
FROM python:3.12-slim

# ── System deps ────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        bash \
        git \
    && rm -rf /var/lib/apt/lists/*

# ── Non-root user (good practice; installers default to $HOME) ──
RUN useradd -ms /bin/bash ligma
USER ligma
WORKDIR /home/ligma

# ── PATH (needed before installers run) ────────────────────────
ENV PATH="/home/ligma/.local/bin:${PATH}"

# ── Install LiteLLM ────────────────────────────────────────────
RUN pip install --no-cache-dir litellm[proxy]

# ── Install Claude Code (native binary, no Node.js required) ───
RUN curl -fsSL https://claude.ai/install.sh | bash

# ── Runtime environment variables ──────────────────────────────
# LiteLLM will proxy requests; Claude Code talks to it locally.
ENV ANTHROPIC_BASE_URL="http://localhost:4000"
ENV ANTHROPIC_API_KEY="local-dev-key"

# Set your real upstream key at runtime:
#   docker run -e OPENROUTER_API_KEY="sk-or-..." ...
# Leaving it empty here so it's never baked into the image.
ENV OPENROUTER_API_KEY=""

# ── LiteLLM config ─────────────────────────────────────────────
COPY --chown=ligma:ligma config.yaml /home/ligma/config.yaml

# ── Expose LiteLLM proxy port ───────────────────────────────────
EXPOSE 4000

# ── Entrypoint ─────────────────────────────────────────────────
# Starts LiteLLM proxy in the background, then drops into bash.
# Override CMD for headless / CI use.
CMD ["bash", "-c", "litellm --config /home/ligma/config.yaml --port 4000 > /tmp/litellm.log 2>&1 & exec bash"]