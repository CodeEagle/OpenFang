# OpenFang 自定义镜像
# 巻加懒猫微服定制配置

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends busybox-static && rm -rf /var/lib/apt/lists/*

# 复制二进制
COPY openfang /usr/local/bin/openfang
RUN chmod +x /usr/local/bin/openfang

# 复制 setup 目录
COPY setup /opt/openfang/setup

# 确保脚本可执行
RUN chmod +x /opt/openfang/setup/entrypoint.sh

EXPOSE 4200

CMD ["/opt/openfang/setup/entrypoint.sh"]
