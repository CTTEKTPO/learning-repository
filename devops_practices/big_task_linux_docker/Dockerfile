FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .

RUN apt-get update && apt-get install -y --no-install-recommends gcc && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y --auto-remove gcc &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

COPY ./app.py .

RUN groupadd -r -g 1001 appuser && \
    useradd -r -u 1001 -g 1001 appuser && \
    chown -R 1001:1001 /app

USER 1001

EXPOSE 5000

CMD ["python", "app.py"]