# docker-python-helloworld

A minimal Python HTTP service built with [FastAPI](https://fastapi.tiangolo.com/), containerised with Docker, and instrumented with [OpenTelemetry](https://opentelemetry.io/) auto-instrumentation out of the box.

## Features

- `GET /` returns `{"message": "Hello, world!"}`
- Automatic traces, metrics, and logs via OpenTelemetry
- Ships to [GitHub Container Registry](https://ghcr.io) on every release tag
- Runs as a non-root user inside the container

---

## Quick start

```bash
docker run -p 8080:8080 ghcr.io/zahlenhelfer/docker-python-helloworld:latest
curl http://localhost:8080/
# {"message":"Hello, world!"}
```

---

## OpenTelemetry configuration

The container uses [`opentelemetry-instrument`](https://opentelemetry-python-contrib.readthedocs.io/en/latest/instrumentation/auto_instrumentation/index.html) as its entrypoint, which automatically instruments FastAPI, uvicorn, and any other supported library without touching application code.

All configuration is done via environment variables at runtime — no code changes needed.

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `OTEL_SERVICE_NAME` | `docker-python-helloworld` | Name of the service as it appears in your observability backend |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | _(none)_ | **Required for export.** Base URL of your OTLP collector, e.g. `http://otel-collector:4318` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `http/protobuf` | Transport protocol. Options: `http/protobuf` (port 4318), `grpc` (port 4317) |
| `OTEL_TRACES_EXPORTER` | `otlp` | Traces exporter. Set to `console` to print spans to stdout |
| `OTEL_METRICS_EXPORTER` | `otlp` | Metrics exporter. Set to `none` to disable |
| `OTEL_LOGS_EXPORTER` | `otlp` | Logs exporter. Set to `none` to disable |

> All standard [OpenTelemetry SDK environment variables](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/) are supported.

### Example: export to an OTLP collector

```bash
docker run -p 8080:8080 \
  -e OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318 \
  -e OTEL_SERVICE_NAME=my-hello-service \
  ghcr.io/zahlenhelfer/docker-python-helloworld:latest
```

### Example: print traces to stdout (no collector needed)

```bash
docker run -p 8080:8080 \
  -e OTEL_TRACES_EXPORTER=console \
  -e OTEL_METRICS_EXPORTER=none \
  -e OTEL_LOGS_EXPORTER=none \
  ghcr.io/zahlenhelfer/docker-python-helloworld:latest
```

---

## Local development

### Prerequisites

- Python 3.13+
- Docker

### Run locally without Docker

```bash
pip install -r requirements.txt
opentelemetry-bootstrap -a install
opentelemetry-instrument python main.py
```

### Build and run with Docker

```bash
docker build -t docker-python-helloworld .
docker run -p 8080:8080 docker-python-helloworld
```

---

## Release workflow

Images are published to `ghcr.io/zahlenhelfer/docker-python-helloworld` automatically via GitHub Actions when a version tag is pushed.

```bash
git tag v1.2.3
git push origin v1.2.3
```

This triggers `.github/workflows/docker-release.yml`, which builds and pushes:

| Tag pushed | Docker tags produced |
|---|---|
| `v1.2.3` | `1.2.3`, `1.2` |

### Pull a specific version

```bash
docker pull ghcr.io/zahlenhelfer/docker-python-helloworld:1.2.3
docker pull ghcr.io/zahlenhelfer/docker-python-helloworld:1.2
```

---

## Project structure

```
.
├── main.py                              # FastAPI application
├── requirements.txt                     # Python dependencies
├── Dockerfile                           # Container image definition
└── .github/
    └── workflows/
        └── docker-release.yml           # CI/CD: build & push on release tag
```
