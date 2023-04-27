FROM espressif/idf



# Install Rust and set default to stable
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    /root/.cargo/bin/rustup default stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Clone rust-build repository and install Rust toolchain
RUN mkdir -p /opt/esp/rust-build
RUN cd /opt/esp/rust-build
RUN git clone https://github.com/esp-rs/rust-build.git /opt/esp/rust-build 
RUN /opt/esp/rust-build/install-rust-toolchain.sh 
RUN     echo ". /opt/esp/rust-build/export-esp.sh" >> ~/.bashrc
RUN echo "LIBCLANG_PATH=/opt/esp/tools/xtensa-esp32-elf-clang/esp-15.0.0-20221201-aarch64-unknown-linux-gnu/esp-clang/lib" >> ~/.bashrc
RUN echo "unset IDF_PATH" >> ~/.bashrc

# Clone ESP-IDF repository and install the toolchain
#ENV IDF_PATH="/opt/esp/idf"
#RUN git clone -b v4.4.4 --recursive https://github.com/espressif/esp-idf.git  $IDF_PATH && \
#    cd $IDF_PATH && \
#    git submodule update --init --recursive && \
#    ./install.sh esp32 && \
#    echo "source /opt/esp/idf/export.sh" >> ~/.bashrc


RUN cargo install ldproxy 

RUN ln -s -T /usr/bin/make /usr/bin/gmake

COPY config.toml /root/.cargo/config.toml

# Configure the environment and set the working directory
WORKDIR /project
ENV PATH="${PATH}:/root/.espressif/tools/xtensa-esp32-elf/esp-12.2.0_20230208/xtensa-esp32-elf/bin:/opt/esp/idf/tools:/opt/esp/idf/components/esptool_py/esptool"

CMD ["/bin/bash"]