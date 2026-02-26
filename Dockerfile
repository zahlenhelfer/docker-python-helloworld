FROM python:3.13-slim

# Run as non-root for security
RUN useradd --create-home --shell /bin/sh appuser

WORKDIR /app

# Copy and set ownership in one layer
COPY --chown=appuser:appuser main.py .

USER appuser

ENTRYPOINT ["python", "main.py"]
