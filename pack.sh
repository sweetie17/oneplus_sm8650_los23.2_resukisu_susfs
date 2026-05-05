#!/bin/bash

# 1. 配置路径
KERNEL_IMAGE="sm8650/out/arch/arm64/boot/Image"
ANYKERNEL_DIR="AnyKernel3"
# 获取当前时间戳，方便区分不同的固件版本
TIMESTAMP=$(date +"%Y%m%d_%H%M")
ZIP_NAME="Kernel_sm8650_${TIMESTAMP}.zip"

echo "开始准备打包..."

# 2. 检查内核镜像是否存在
if [ ! -f "$KERNEL_IMAGE" ]; then
    echo "❌ 错误: 找不到内核镜像文件: $KERNEL_IMAGE"
    echo "请先运行 build.sh 确保编译成功。"
    exit 1
fi

# 3. 清理 AnyKernel3 目录中的旧残留
# 避免把上一次的 Image 或上次打包产生的旧文件也压进去
echo "=> 清理 AnyKernel3 临时文件..."
rm -f "$ANYKERNEL_DIR"/Image
rm -f "$ANYKERNEL_DIR"/*.zip

# 4. 拷贝最新镜像
echo "=> 拷贝 Image 到 $ANYKERNEL_DIR..."
cp "$KERNEL_IMAGE" "$ANYKERNEL_DIR/Image"

# 5. 开始打包
echo "=> 正在生成压缩包: $ZIP_NAME"
# 使用 ( ) 进入子 shell 运行，这样脚本执行完后你的终端目录不会改变
(
    cd "$ANYKERNEL_DIR" || exit 1
    # -r: 递归
    # -q: 安静模式（可选，如果想看过程可以去掉）
    # -x: 排除不需要压进包里的文件（如 .git 文件夹）
    zip -r9 "../$ZIP_NAME" . -x ".git/*" "README.md" "*placeholder*"
)

# 6. 结果检查
if [ -f "$ZIP_NAME" ]; then
    echo "---------------------------------------"
    echo "✅ 打包完成!"
    echo "文件名: $ZIP_NAME"
    # 创建一个固定命名的软链接，方便刷机工具脚本调用
    ln -sf "$ZIP_NAME" AnyKernel3-Latest.zip
    echo "软链接: AnyKernel3-Latest.zip -> $ZIP_NAME"
else
    echo "❌ 打包失败!"
    exit 1
fi
