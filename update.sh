#!/bin/bash

set -e

echo "Starting Update..."

update_or_clone() {
    local REPO_DIR="$1"
    local REPO_URL="$2"
    local BRANCH="$3"
    
    echo -e "\n=> 处理仓库: $REPO_DIR"
    
    if [ -d "$REPO_DIR" ]; then
        echo "   正在重置并更新本地修改..."
        (
            cd "$REPO_DIR" || exit 1
            git checkout .
            git clean -df
            if [ -n "$BRANCH" ]; then
                git pull origin "$BRANCH" --depth=1
            else
                git pull --depth=1
            fi
        )
    else
        echo "   正在克隆新仓库..."
        if [ -n "$BRANCH" ]; then
            git clone --depth=1 -b "$BRANCH" "$REPO_URL" "$REPO_DIR"
        else
            git clone "$REPO_URL" "$REPO_DIR"
        fi
    fi
}

# 1. 更新各组件
update_or_clone "sm8650" "https://github.com/lineageos/android_kernel_oneplus_sm8650.git" "lineage-23.2"
update_or_clone "sm8650-modules" "https://github.com/lineageos/android_kernel_oneplus_sm8650-modules.git" "lineage-23.2"
update_or_clone "susfs" "https://gitlab.com/simonpunk/susfs4ksu.git" "gki-android14-6.1"
update_or_clone "AnyKernel3" "https://github.com/Kernel-SU/AnyKernel3.git" ""

# 2. 进入内核目录
cd sm8650 || exit 1

# 3. 安装 KernelSU 
echo "=> Installing KernelSU..."
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash -s main

# 4. 准备 SUSFS 文件
echo "=> Preparing SUSFS files..."
cp ../susfs/kernel_patches/50_add_susfs_in_gki-android14-6.1.patch .
cp -r ../susfs/kernel_patches/fs/* ./fs/
cp -r ../susfs/kernel_patches/include/linux/* ./include/linux/

# 5. 应用补丁
echo "=> Applying SUSFS patch..."
if patch -p1 < 50_add_susfs_in_gki-android14-6.1.patch; then
    echo "   补丁应用成功！"
else
    echo "   [警告] 补丁存在部分冲突，请检查 .rej 文件。"
    # 查找并列出冲突文件供参考
    find . -name "*.rej"
fi

# 6. 其他配置修改
touch .scmversion

echo "=> MODIFYING DEFCONFIG"
CONFIG_FILE="arch/arm64/configs/gki_defconfig"
if [ -f "$CONFIG_FILE" ]; then
    sed -i "s|CONFIG_MODULE_SIG_PROTECT=y|CONFIG_MODULE_SIG_PROTECT=n|" "$CONFIG_FILE"
    echo "CONFIG_KSU=y" >> "$CONFIG_FILE"
    echo "CONFIG_KSU_SUSFS=y" >> "$CONFIG_FILE"
fi

echo -e "\n=> Update Script Finished!"