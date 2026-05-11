FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    gcc-riscv64-linux-gnu \
    binutils-riscv64-linux-gnu \
    gdb-multiarch \
    qemu-system-misc \
    make \
    git \
    bc

WORKDIR /home/xv6

COPY . .

# الحل السحري: استخدام qemu-nox بدلاً من qemu
# nox تعني "No X Windows" أي تشغيل داخل التيرمينال مباشرة
CMD ["make", "TOOLPREFIX=riscv64-linux-gnu-", "qemu-nox"]