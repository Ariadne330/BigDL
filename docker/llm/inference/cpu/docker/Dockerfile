FROM ubuntu:22.04

ARG http_proxy
ARG https_proxy
ARG PIP_NO_CACHE_DIR=false
ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONUNBUFFERED=1

COPY ./start-notebook.sh /llm/start-notebook.sh

# Install PYTHON 3.9
RUN env DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt install software-properties-common libunwind8-dev vim less -y && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get install -y python3.9 git curl wget && \
    rm /usr/bin/python3 && \
    ln -s /usr/bin/python3.9 /usr/bin/python3 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apt-get install -y python3-pip python3.9-dev python3-wheel python3.9-distutils && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
# Install FastChat from source requires PEP 660 support
    python3 get-pip.py && \
    rm get-pip.py && \
    pip install --upgrade requests argparse urllib3 && \
    pip3 install --no-cache-dir --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && \
    pip install --pre --upgrade bigdl-llm[all] && \
# Download bigdl-llm-tutorial
    cd /llm && \
    pip install --upgrade jupyterlab && \
    git clone https://github.com/intel-analytics/bigdl-llm-tutorial && \
    chmod +x /llm/start-notebook.sh && \
# Download chat.py script
    pip install --upgrade colorama && \
    wget -P /llm https://raw.githubusercontent.com/intel-analytics/BigDL/main/python/llm/portable-zip/chat.py && \
# Download all-in-one benchmark
    git clone https://github.com/intel-analytics/BigDL && \
    cp -r ./BigDL/python/llm/dev/benchmark/ ./benchmark && \
# Install all-in-one dependencies
    apt-get install -y numactl && \
    pip install --upgrade omegaconf && \
    pip install --upgrade pandas && \
# Install vllm dependencies
    pip install --upgrade fastapi && \
    pip install --upgrade "uvicorn[standard]" && \
# Copy vLLM-Serving
    cp -r ./BigDL/python/llm/example/CPU/vLLM-Serving/ ./vLLM-Serving && \
    rm -rf ./BigDL

ENTRYPOINT ["/bin/bash"]