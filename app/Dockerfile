# ================================
# Stage 1: Build dependencies
# ================================
FROM python:3.12-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# ================================
# Stage 2: Runtime image
# ================================
FROM python:3.12-slim

# Update OS packages and remove apt cache
RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create non-root application user
RUN useradd --create-home --shell /usr/sbin/nologin appuser

# Copy Python dependencies
COPY --from=builder /install /usr/local

# Copy application
COPY --chown=appuser:appuser app.py .

# Run as non-root user
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
