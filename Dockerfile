# Use an official Python runtime (Alpine variant)
FROM python:3.12-alpine

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install dependencies
RUN apk add --no-cache build-base

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the rest of the application
COPY . .

# Set entrypoint (could also use CMD)
ENTRYPOINT ["python", "app.py"]
