FROM python:3.13-slim

# Run as non-root for security
RUN useradd --create-home --shell /bin/sh appuser

WORKDIR /app

# Install dependencies and auto-detect instrumentation packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    opentelemetry-bootstrap -a install

# Copy app and set ownership in one layer
COPY --chown=appuser:appuser main.py .

USER appuser

EXPOSE 8080

# OTel defaults — override OTEL_EXPORTER_OTLP_ENDPOINT at runtime
ENV OTEL_SERVICE_NAME=docker-python-helloworld \
    OTEL_TRACES_EXPORTER=otlp \
    OTEL_METRICS_EXPORTER=otlp \
    OTEL_LOGS_EXPORTER=otlp \
    OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf

ENTRYPOINT ["opentelemetry-instrument", "python", "main.py"]
