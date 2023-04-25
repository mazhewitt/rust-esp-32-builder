FROM debian:bullseye-slim

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bison \
        ccache \
        cmake \
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
        python-dev \
        unzip \
        wget \
        xz-utils  \
        libclang-dev && \
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
RUN git clone -b v4.4.4 --recursive https://github.com/espressif/esp-idf.git  $IDF_PATH && \
    cd $IDF_PATH && \
    git submodule update --init --recursive && \
    ./install.sh esp32 && \
    echo "source /opt/esp/idf/export.sh" >> ~/.bashrc


RUN cargo install cargo-generate &&\
    cargo install ldproxy &&\
    cargo install espup


COPY config.toml /root/.cargo/config.toml

# Configure the environment and set the working directory
WORKDIR /project
ENV PATH="${PATH}:/root/.espressif/tools/xtensa-esp32-elf/esp-12.2.0_20230208/xtensa-esp32-elf/bin:/opt/esp/idf/tools:/opt/esp/idf/components/esptool_py/esptool"

CMD ["/bin/bash"]