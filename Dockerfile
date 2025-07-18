# Build stage for installing dependencies
FROM python:3.10-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements file first to leverage Docker cache
COPY requirements.docker.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.docker.txt

# Final stage
FROM python:3.10-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy wheels from builder stage
COPY --from=builder /app/wheels /wheels
COPY requirements.txt .

# Install packages but skip tensorflow-metal
RUN pip install --no-cache /wheels/*

# Copy application code
COPY . .

EXPOSE 8501

ENTRYPOINT ["streamlit", "run", "Xenty.py", "--server.port=8501", "--server.address=0.0.0.0"]