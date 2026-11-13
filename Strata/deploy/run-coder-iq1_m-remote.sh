#!/bin/sh
# Strata Coder IQ1_M 启动脚本 (远程访问版)
# 监听 0.0.0.0 以支持远程访问

cd "/home/wangwei/wei/workspacePy/infra-inference/Strata-main"
export STRATA_HOME=/data1/disk2/strata/config

exec ".venv/bin/python" "serve/server.py" \
  "--engine" "strata" \
  "--config" "strata-coder-iq1_m.json" \
  "--port" "8080" \
  "--host" "0.0.0.0"
