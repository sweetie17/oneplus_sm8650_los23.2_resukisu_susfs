#!/bin/bash

# 1. 配置路径 (建议使用绝对路径)
CLANG_ROOT="$HOME/android/toolchains/clang-r563880c/bin"
KERNEL_DIR="sm8650"
OUT_DIR="out"

# 检查工具链是否存在
if [ ! -d "$CLANG_ROOT" ]; then
    echo "错误: 找不到 Clang 工具链路径: $CLANG_ROOT"
    exit 1
fi

# 2. 设置环境变量
export PATH="${CLANG_ROOT}:$PATH"
export LLVM=1
export LLVM_IAS=1
export ARCH=arm64
export SUBARCH=arm64

# 打印编译器信息以供核对
echo "--- 正在使用编译器: ---"
clang --version | head -n 1
echo "----------------------"

# 3. 进入内核目录
cd "$KERNEL_DIR" || { echo "错误: 无法进入目录 $KERNEL_DIR"; exit 1; }

# 4. 预处理输出目录 (可选：添加一个参数用于清理)
if [ "$1" == "clean" ]; then
    echo "正在清理 out 目录..."
    rm -rf "$OUT_DIR"
fi

mkdir -p "$OUT_DIR"

# 5. 生成配置文件
echo "=> 正在生成 Defconfig..."
make O="$OUT_DIR" gki_defconfig vendor/pineapple_GKI.config vendor/oplus/pineapple_GKI.config

# 6. 开始编译
echo "=> 正在开始编译..."
# 使用 nproc 自动获取核心数
make -j$(nproc) O="$OUT_DIR" Image 2>&1 | tee build.log

# 7. 检查编译结果
if [ -f "$OUT_DIR/arch/arm64/boot/Image" ]; then
    echo -e "\n✅ 编译成功!"
    echo "内核镜像位于: $KERNEL_DIR/$OUT_DIR/arch/arm64/boot/Image"
else
    echo -e "\n❌ 编译失败! 请检查 build.log"
    exit 1
fi