
docker build -t mazhewitt/esp32-builder:0.1 . 

docker run --rm -v $(pwd):/project mazhewitt/esp32-builder:0.1 cargo build --target xtensa-esp32-none-elf


