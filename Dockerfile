FROM debian:bullseye-slim

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bison \
        ccache \
        curl \
        dfu-util \
        flex \
        g++ \
        gcc \
        git \
        gperf \
        libc6-dev \
        libffi-dev \
        libpython2.7 \
        libssl-dev \
        libudev-dev \
        libusb-1.0-0 \
        make \
        ninja-build \
        pkg-config \
        python3 \
        python3-venv \
        python3-pip \
        unzip \
        wget \
        xz-utils && \
    rm -rf /var/lib/apt/lists/* 


# Install Rust and set default to stable
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    /root/.cargo/bin/rustup default stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Clone rust-build repository and install Rust toolchain
RUN git clone https://github.com/esp-rs/rust-build.git /opt/esp/rust-build && \
    cd /opt/esp/rust-build && \
    ./install-rust-toolchain.sh && \
    . ./export-esp.sh && \
    echo ". /opt/esp/rust-build/export-esp.sh" >> ~/.bashrc

# Clone ESP-IDF repository and install the toolchain
ENV IDF_PATH="/opt/esp/idf"
RUN git clone --branch v5.0.1 --recursive https://github.com/espressif/esp-idf.git $IDF_PATH && \
    cd $IDF_PATH && \
    git submodule update --init --recursive && \
    ./install.sh esp32 && \
    echo "source /opt/esp/idf/export.sh" >> ~/.bashrc

RUN cargo install ldproxy

# Install libclang for xtensa
RUN wget https://github.com/espressif/llvm-project/releases/download/esp-15.0.0-20230404/libs_llvm-esp-15.0.0-20230404-linux-arm64.tar.xz &&\
    tar -xf libs_llvm-esp-15.0.0-20230404-linux-arm64.tar.xz && \
    rm libs_llvm-esp-15.0.0-20230404-linux-arm64.tar.xz && \
    mv esp-clang /opt/esp/ &&\
    echo "export LIBCLANG_PATH=/opt/esp/esp-clang/lib" >> ~/.bashrc


RUN pip install cmake --upgrade

# Configure the environment and set the working directory
# Add script to source environment variables and run commands
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
WORKDIR /project

CMD ["/bin/bash"]