# Dockerfile ottimizzato per Render (Linux deployment fix)
FROM python:3.11-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV HF_HOME=/app/models
ENV MODELSCOPE_CACHE=/app/models

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ffmpeg \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create models directory
RUN mkdir -p /app/models

# Initialize git submodules for frontend
RUN git submodule update --init --recursive || echo "No submodules to initialize"

# Expose port
EXPOSE 12393

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:12393/ || exit 1

# Start the application
CMD ["python", "run_server.py", "--config", "conf.production.yaml", "--host", "0.0.0.0", "--port", "12393"]
