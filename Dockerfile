FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04

WORKDIR /app
COPY . /app

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
    build-essential software-properties-common \
    python3.11 python3.11-dev python3.11-venv \
    sox libsox-dev ffmpeg curl && \
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:deadsnakes/ppa

RUN mkdir -p ./dependencies && \
    curl -LJ -o ./dependencies/fairseq-0.12.2-cp311-cp311-linux_x86_64.whl --create-dirs \
    https://huggingface.co/JackismyShephard/ultimate-rvc/resolve/main/fairseq-0.12.2-cp311-cp311-linux_x86_64.whl

RUN python3.11 -m venv /app/venv && \
    . /app/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --timeout=500 --retries=10 -r requirements.txt && \
    pip install faiss-cpu==1.7.3

RUN /app/venv/bin/python ./src/init.py

EXPOSE 7860

CMD ["sh", "-c", "echo 'Starting Ultimate RVC' && /app/venv/bin/python ./src/app.py --listen --listen-host 0.0.0.0 --listen-port 7860"]
