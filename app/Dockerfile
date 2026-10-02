FROM python:3.12-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


FROM python:3.12-slim

RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN useradd --create-home --shell /usr/sbin/nologin appuser

COPY --from=builder /install /usr/local

COPY --chown=appuser:appuser app.py .

USER appuser

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
