#!/bin/bash

# 定义要清理的内核目录，默认为当前目录下的 sm8650
KERNEL_DIR="./sm8650"

echo "开始清理补丁残留文件..."

# 检查目录是否存在
if [ ! -d "$KERNEL_DIR" ]; then
    echo "错误: 找不到目录 $KERNEL_DIR"
    exit 1
fi

# 使用 find 命令查找并删除
# -name "*.orig": 查找 patch 命令产生的备份文件
# -name "*.rej":  查找补丁失败产生的冲突记录文件
# -type f:       只针对文件操作
# -delete:       直接删除找到的文件
find "$KERNEL_DIR" -type f \( -name "*.orig" -o -name "*.rej" \) -print -delete

echo "---------------------------------------"
echo "清理完成！所有 .orig 和 .rej 文件已移除。"