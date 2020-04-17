FROM ubuntu:18.04

RUN apt update && \
    apt install -y sysstat \
    build-essential \
    strace

WORKDIR /workspace

CMD ["/bin/bash"]