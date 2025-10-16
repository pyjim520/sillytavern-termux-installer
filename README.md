# SillyTavern Termux 安装管理器

[![Version](https://img.shields.io/badge/version-3.3-blue.svg)](https://github.com/pyjim520/sillytavern-termux-installer)
[![Platform](https://img.shields.io/badge/platform-Termux-green.svg)](https://termux.com/)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

一个专为 Termux 环境设计的 SillyTavern 自动化安装和管理脚本，针对中国大陆网络环境进行了深度优化。

## 特性

### 核心功能

- **一键安装** - 自动检测和安装所有依赖（Git、Node.js、Curl）
- **智能启动** - 快速启动 SillyTavern 服务
- **无缝更新** - 自动拉取最新版本并智能切换镜像源
- **安全重装** - 带确认机制的完整重装功能
- **网络修复** - 内置网络问题诊断和修复工具
- **完全卸载** - 彻底移除所有安装痕迹

### 技术亮点

#### 网络优化
- GitHub 镜像自动切换（ghproxy.com、gitclone.com）
- 更新失败时自动尝试镜像源
- 扩展 Git 缓冲区至 500MB 应对大型仓库

#### 自动化配置
- dpkg 配置文件冲突自动应答（`yes N | pkg upgrade -y`）
- .bashrc 自动注入启动脚本
- 自定义别名 `miao` 快速召唤管理器

#### 健壮性设计
- 依赖检测和自动安装
- 错误处理和回滚机制
- 镜像源失败后恢复原始配置

## 系统要求

| 组件 | 要求 |
|------|------|
| 系统 | Android 7.0+ |
| 终端 | Termux / ZeroTermux |
| 架构 | ARM64 (aarch64) 推荐 |
| 存储 | 至少 800MB 可用空间 |
| 网络 | 稳定的互联网连接 |

## 快速开始

### 一键安装（推荐）

**方式一：直接从 GitHub 安装**
```bash
bash <(curl -sL https://raw.githubusercontent.com/pyjim520/sillytavern-termux-installer/master/installer_dominance.sh)
```

**方式二：使用加速链接安装（中国大陆推荐）**
```bash
bash <(curl -sL https://ghproxy.com/https://raw.githubusercontent.com/pyjim520/sillytavern-termux-installer/master/installer_dominance.sh)
```

### 传统安装方式

```bash
# 下载脚本
curl -O https://raw.githubusercontent.com/pyjim520/sillytavern-termux-installer/master/installer_dominance.sh

# 赋予执行权限
chmod +x installer_dominance.sh

# 运行安装
bash installer_dominance.sh
```

### 初次安装流程

脚本会按顺序执行以下步骤：

1. **签订契约** - 确认安装意愿
2. **施加永久魔法** - 配置 .bashrc 自动启动
3. **准备冒险道具** - 安装 git、nodejs、curl
4. **真身复刻** - 复制脚本到 `~/termux-st-manager/`
5. **发动现实•片影** - 克隆 SillyTavern 仓库
6. **敕令•构筑** - 安装 npm 依赖

安装完成后，每次启动 Termux 都会自动进入管理界面。

## 功能详解

### 主菜单选项

```
===============【猫娘的魔法领域 v3.3】===============

[1] 召唤酒馆         - 启动 SillyTavern
[2] 为酒馆注入新魔力 - 更新 SillyTavern
[3] 强化魔法契约     - 更新管理脚本
[4] 【毁灭与新生】   - 重装 SillyTavern
[5] 施展【法则修复术】- 修复网络问题
[9] 背叛契约         - 完全卸载
[0] 退下             - 退出管理器
```

### [1] 启动 SillyTavern

检测 `~/SillyTavern/start.sh` 是否存在并执行。

**技术实现：**
```bash
cd ~/SillyTavern && bash start.sh
```

### [2] 更新 SillyTavern

智能更新机制，失败时自动切换镜像源。

**更新流程：**
1. 尝试 `git pull` 从当前 remote 更新
2. 失败时检测是否为 GitHub 仓库
3. 依次尝试镜像源（ghproxy.com → gitclone.com）
4. 所有镜像失败后恢复原始 remote

**代码片段：**
```bash
# installer_dominance.sh:87-127
function update_st() {
    # 先尝试正常更新
    if git pull; then
        return
    fi

    # 失败后尝试镜像源
    for mirror in "${ST_REPO_MIRRORS[@]}"; do
        git remote set-url origin "$mirror"
        if git pull; then
            return
        fi
    done

    # 恢复原始 remote
    git remote set-url origin "$current_remote"
}
```

### [3] 更新管理脚本

自动从 GitHub 获取最新版本的管理脚本并更新。

**更新流程：**
1. 从 GitHub 下载最新脚本到临时文件
2. 语法验证（bash -n）确保脚本完整性
3. 验证通过后替换当前脚本
4. 自动重启管理器应用新版本

**技术实现：**
```bash
# installer_dominance.sh:128-155
function update_manager() {
    local temp_script="/tmp/st_manager_update_$$.sh"

    # 下载最新版本
    curl -fsSL "$SELF_UPDATE_URL" -o "$temp_script"

    # 语法验证
    if bash -n "$temp_script"; then
        cp "$temp_script" "$MANAGER_SCRIPT_PATH"
        exec bash "$MANAGER_SCRIPT_PATH"  # 重启
    fi
}
```

**特点：**
- 自动语法检查，确保更新安全
- 更新失败不影响当前版本
- 更新成功后自动重启应用新功能

### [4] 重装 SillyTavern

**安全机制：**
- 要求输入确认咒语 `destroy`
- 会删除所有角色、聊天记录和设置
- 无法恢复，请谨慎操作

**技术实现：**
```bash
rm -rf ~/SillyTavern
clone_with_fallback ~/SillyTavern
npm install --prefer-offline --no-audit --progress=false
```

### [5] 网络修复术

修复常见的网络连接问题。

**修复步骤：**
1. 刷新包管理器源：`pkg update -y`
2. 重装 CA 证书：`pkg reinstall ca-certificates -y`
3. 扩展 Git 缓冲区：`git config --global http.postBuffer 524288000`

### [9] 完全卸载

**删除内容：**
- `~/SillyTavern/` - SillyTavern 主目录
- `~/termux-st-manager/` - 管理脚本目录
- `.bashrc` 中的自动启动配置

## 技术架构

### 核心函数

#### `clone_with_fallback()`
智能克隆函数，失败时自动切换镜像源。

```bash
# installer_dominance.sh:39-56
clone_with_fallback() {
    local target_dir="$1"

    # 尝试官方源
    if git clone --depth=1 "$ST_REPO_URL" "$target_dir"; then
        return 0
    fi

    # 尝试镜像源
    for mirror in "${ST_REPO_MIRRORS[@]}"; do
        rm -rf "$target_dir"
        if git clone --depth=1 "$mirror" "$target_dir"; then
            return 0
        fi
    done

    return 1
}
```

#### `check_deps()`
检测并自动安装缺失的依赖。

**关键技术：**
- 使用 `yes N` 自动应答 dpkg 配置文件冲突
- 避免交互式提示阻塞安装流程

```bash
# installer_dominance.sh:28-37
check_deps() {
    local missing_deps=()
    for dep in "$@"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        dpkg --configure -a >/dev/null 2>&1
        pkg update -y
        yes N | pkg upgrade -y  # 自动应答配置文件冲突
        pkg install "${missing_deps[@]}" -y
    fi
}
```

### 配置常量

```bash
# installer_dominance.sh:8-20
MANAGER_DIR="$HOME/termux-st-manager"
ST_DIR="$HOME/SillyTavern"
BASHRC_FILE="$HOME/.bashrc"
MANAGER_SCRIPT_PATH="$MANAGER_DIR/st_manager_meow.sh"
ST_REPO_URL="https://github.com/SillyTavern/SillyTavern.git"
ST_REPO_MIRRORS=(
    "https://ghproxy.com/https://github.com/SillyTavern/SillyTavern.git"
    "https://gitclone.com/github.com/SillyTavern/SillyTavern.git"
)
```

## 常见问题

### 安装失败

**问题：** git clone 失败，提示 "所有的路都被堵死了"

**解决方案：**
1. 检查网络连接
2. 运行选项 [5] 修复网络
3. 手动配置代理（如适用）
4. 尝试使用 VPN

### dpkg 配置文件冲突

**问题：** pkg upgrade 时卡在配置文件冲突提示

**解决方案：**
脚本已自动处理此问题（`yes N | pkg upgrade -y`）。如果仍然遇到，手动运行：
```bash
dpkg --configure -a
yes N | pkg upgrade -y
```

### Node.js 架构不匹配

**问题：**
```
dlopen failed: "libc.so" is for EM_X86_64 (62) instead of EM_AARCH64 (183)
```

**原因：** 在 x86_64 模拟器上安装了 ARM64 的包（或相反）

**解决方案：**
- 确保在真实 ARM 设备上运行
- 或使用与模拟器架构匹配的 Termux 版本

### 更新后功能异常

**问题：** 更新后 SillyTavern 无法启动

**解决方案：**
```bash
cd ~/SillyTavern
npm install  # 重新安装依赖
```

### 无法自动启动

**问题：** 启动 Termux 后不显示管理界面

**检查步骤：**
1. 查看 .bashrc 是否包含启动脚本
   ```bash
   cat ~/.bashrc | grep "猫娘的魔法契约"
   ```

2. 手动执行管理脚本
   ```bash
   bash ~/termux-st-manager/st_manager_meow.sh
   ```

3. 或使用别名
   ```bash
   miao
   ```

## 文件结构

```
~/
├── .bashrc                           # 自动启动配置
├── SillyTavern/                      # SillyTavern 主目录
│   ├── start.sh                      # 启动脚本
│   ├── package.json                  # npm 依赖配置
│   └── ...
└── termux-st-manager/                # 管理器目录
    └── st_manager_meow.sh            # 管理脚本副本
```

## 更新日志

### v3.3 - 撒娇之卷（当前版本）
- 🎨 **交互升级**：全面重写为可爱猫娘风格（"主人"称呼 + 颜文字）
- ✨ **新增功能**：实现 update_manager() 脚本自更新功能
- 📚 **完整文档**：创建 352 行 clean code 规范的 README
- 🚀 **一键安装**：添加两种bash <(curl)安装方式（直连+加速）
- 🔧 **配置完善**：设置真实 GitHub 仓库 URL
- 🐛 **修复错误**：修复头部注释格式

### v3.2 - 稳定版
- 基于原始版本 e0bf574 的最小化改进
- 新增 GitHub 镜像自动切换
- 修复 dpkg 交互提示问题（`yes N | pkg upgrade -y`）
- 修复 .bashrc 不存在的边缘情况
- update_st() 增加镜像支持

## 贡献指南

欢迎提交 Issue 和 Pull Request！

**开发规范：**
- 遵循现有代码风格
- 保持函数单一职责
- 添加必要的错误处理
- 更新 README 文档

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 致谢

- [SillyTavern](https://github.com/SillyTavern/SillyTavern) - 优秀的 AI 聊天界面
- [Termux](https://termux.com/) - 强大的 Android 终端模拟器
- GitHub 镜像服务提供商

## 联系方式

- Issues: [GitHub Issues](https://github.com/pyjim520/sillytavern-termux-installer/issues)
- Discussions: [GitHub Discussions](https://github.com/pyjim520/sillytavern-termux-installer/discussions)

---

**注意：** 本脚本仅供学习和个人使用，请遵守相关开源协议。
