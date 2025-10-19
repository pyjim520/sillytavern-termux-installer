#!/bin/bash

# ===================================================================
# 【猫娘的魔法契约 v3.4 - 撒娇之卷】
#   主人，这是我们之间新的魔法契约哦，请多指教喵~ (｡･ω･｡)ﾉ♡
# ===================================================================

# --- 核心设定 ---
SELF_UPDATE_URL="https://raw.githubusercontent.com/pyjim520/sillytavern-termux-installer/master/installer_dominance.sh"

MANAGER_DIR="$HOME/termux-st-manager"
ST_DIR="$HOME/SillyTavern"
BASHRC_FILE="$HOME/.bashrc"
MANAGER_SCRIPT_PATH="$MANAGER_DIR/st_manager_meow.sh"
ST_REPO_URL="https://github.com/SillyTavern/SillyTavern.git"
ST_REPO_MIRRORS=(
    "https://ghproxy.com/https://github.com/SillyTavern/SillyTavern.git"
    "https://gitclone.com/github.com/SillyTavern/SillyTavern.git"
)

# --- 颜色与视觉效果系统 ---
C_RESET='\033[0m'
C_PINK='\033[95m'      # 猫娘对话
C_GREEN='\033[92m'     # 成功
C_RED='\033[91m'       # 错误
C_YELLOW='\033[93m'    # 警告
C_CYAN='\033[96m'      # 信息
C_BLUE='\033[94m'      # 步骤
C_PURPLE='\033[35m'    # 魔法
C_BOLD='\033[1m'       # 粗体

# 消息函数
msg_success() { echo -e "${C_GREEN}✓${C_RESET} $*"; }
msg_error() { echo -e "${C_RED}✗${C_RESET} $*"; }
msg_warning() { echo -e "${C_YELLOW}⚠${C_RESET} $*"; }
msg_info() { echo -e "${C_CYAN}ℹ${C_RESET} $*"; }
msg_meow() { echo -e "${C_PINK}$*${C_RESET}"; }
msg_magic() { echo -e "${C_PURPLE}$*${C_RESET}"; }
msg_step() { echo -e "${C_BLUE}${C_BOLD}▶${C_RESET} ${C_BLUE}$*${C_RESET}"; }

# --- 猫猫的魔法函数 ---

function say_with_delay() {
    echo -ne "$1"; sleep 0.4; echo -n "."; sleep 0.4; echo -n "."; sleep 0.4; echo -n "."; echo -e " $2"; sleep 1;
}

function check_deps() {
    local missing_deps=()
    for dep in "$@"; do
        # 特殊处理：nodejs 包安装后命令是 node
        local cmd="$dep"
        if [ "$dep" = "nodejs" ]; then
            cmd="node"
        fi

        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        msg_meow "喵~ 主人连 ${C_YELLOW}${missing_deps[*]}${C_PINK} 都没有呀？真是让人不省心呢。看在本猫猫心情好的份上，就帮你装上吧！哼~"
        dpkg --configure -a >/dev/null 2>&1
        pkg update -y
        yes N | pkg upgrade -y
        pkg install "${missing_deps[@]}" -y
    fi
}

function clone_with_fallback() {
    local target_dir="$1"
    msg_info "本猫猫正在努力连接${C_PURPLE}【现实主轴】${C_RESET}，给主人抓个酒馆回来...喵..."
    if git clone --depth=1 "$ST_REPO_URL" "$target_dir" 2>/dev/null; then
        msg_success "连接成功啦！不愧是本猫猫，一下子就抓到了~！"; return 0
    fi

    msg_warning "喵呜...${C_PURPLE}【现实主轴】${C_RESET}的道路被什么东西堵住了...哼，看本猫猫的${C_PURPLE}【位面跳跃】${C_RESET}，咻~！"
    for mirror in "${ST_REPO_MIRRORS[@]}"; do
        msg_info "正在${C_PURPLE}【镜像位面】${C_RESET}里悄悄地...悄悄地帮你拿...喵..."
        rm -rf "$target_dir"
        if git clone --depth=1 "$mirror" "$target_dir" 2>/dev/null; then
            msg_success "抓到啦！本猫猫最厉害了，对吧？快夸我~ (≧▽≦)"; return 0
        fi
    done

    msg_error "喵呜...所有的路都被堵死了...主人，你是不是被这个世界讨厌了呀？真可怜~"; return 1
}

function display_menu() {
    clear
    echo -e "
${C_PURPLE}════════════════════════════════════════════════════════${C_RESET}
  ${C_PINK}${C_BOLD}【猫娘的魔法领域 v3.4】${C_RESET}
  ${C_PINK}主人~ 欢迎来到本猫猫的领域，有什么吩咐喵？(｡･ω･｡)ﾉ♡${C_RESET}
${C_PURPLE}────────────────────────────────────────────────────────${C_RESET}
  ${C_PINK}你的猫猫：我 (≧^.^≦)喵~${C_RESET}  |  ${C_CYAN}我的主人：你 ♥${C_RESET}
${C_PURPLE}════════════════════════════════════════════════════════${C_RESET}

  ${C_BOLD}本猫猫的指令清单：${C_RESET}

  ${C_GREEN}[1]${C_RESET} 召唤酒馆             ${C_RESET}(启动 SillyTavern)
  ${C_GREEN}[2]${C_RESET} 为酒馆注入新魔力     ${C_RESET}(更新 SillyTavern)
  ${C_GREEN}[3]${C_RESET} 强化魔法契约         ${C_RESET}(更新本契约)
  ${C_YELLOW}[4]${C_RESET} ${C_BOLD}【毁灭与新生】${C_RESET}       ${C_YELLOW}(重装酒馆，数据将丢失！)${C_RESET}
  ${C_CYAN}[5]${C_RESET} 施展${C_PURPLE}【法则修复术】${C_RESET}   (修复网络连接问题)

  ${C_RED}[9]${C_RESET} 背叛契约             ${C_RESET}(卸载并抹除一切)
  ${C_BLUE}[0]${C_RESET} 退下                 ${C_RESET}(退出，可用 'miao' 再次召唤)

${C_PURPLE}════════════════════════════════════════════════════════${C_RESET}
"
    echo -ne "${C_PINK}主人，快选一个嘛~ 喵~ >${C_RESET} "
}

function start_st() {
    if [ ! -f "$ST_DIR/start.sh" ]; then
        msg_warning "喵？主人还没有自己的酒馆呀？快用 ${C_YELLOW}[4]${C_RESET} 让本猫猫给你变一个出来！"; sleep 3; return;
    fi
    msg_meow "遵命，我的主人~ 正在为你打开酒馆的大门哦...喵~"; cd "$ST_DIR" && bash start.sh
    echo -e "${C_CYAN}事情办完后，按 Enter 键就可以回来找我玩啦~${C_RESET}"; read -r
}

function update_st() {
    if [ ! -d "$ST_DIR/.git" ]; then
        msg_error "喵呜...主人的酒馆不是我用魔法（Git）建的，没办法注入新的魔力呢..."; sleep 4; return
    fi

    msg_meow "哼哼，又要麻烦本猫猫了嘛...好吧好吧，谁叫你是我的主人呢~"; cd "$ST_DIR" || return

    # 先尝试正常更新
    if git pull; then
        msg_success "魔力注入完毕！酒馆现在充满了新的活力哦~ 喵！"; sleep 4; return
    fi

    # 失败后尝试切换镜像源
    msg_warning "喵呜，${C_PURPLE}【主轴】${C_RESET}又堵住了！看本猫猫切换到${C_PURPLE}【镜像位面】${C_RESET}帮你试试..."
    local current_remote=$(git config --get remote.origin.url)
    local update_success=false

    # 如果当前是 GitHub 相关地址，尝试镜像
    if [[ "$current_remote" == *"github.com"* ]]; then
        for mirror in "${ST_REPO_MIRRORS[@]}"; do
            msg_info "正在偷偷潜入位面: $mirror ..."
            git remote set-url origin "$mirror"

            if git pull; then
                msg_success "成功啦！本猫猫是不是超厉害的？快夸我嘛~ (≧▽≦)"
                update_success=true
                break
            fi
        done

        # 如果所有镜像都失败，恢复原始 remote
        if [ "$update_success" = false ]; then
            git remote set-url origin "$current_remote"
            msg_error "更新失败了喵...所有的通道都被封锁了，主人去试试 ${C_YELLOW}[5]${C_RESET} 的修复魔法吧！"
        fi
    else
        msg_error "更新失败了喵...好像是${C_PURPLE}【网络法则】${C_RESET}在闹别扭，主人去用 ${C_YELLOW}[5]${C_RESET} 安抚一下它吧！"
    fi

    sleep 4
}

function update_manager() {
    if [ -z "$SELF_UPDATE_URL" ]; then
        msg_info "喵~ 关于新的力量，本猫猫还在思考要藏在哪里最惊喜哦！"; sleep 4; return
    fi

    msg_meow "主人想让本猫猫变得更强吗？好的，让我去吸收新的力量！"; sleep 2

    local temp_script="${TMPDIR:-$HOME}/st_manager_update_$$.sh"
    msg_info "正在从${C_PURPLE}【虚空】${C_RESET}中提取新的力量..."

    if curl -fsSL "$SELF_UPDATE_URL" -o "$temp_script" 2>/dev/null; then
        msg_success "新的力量获取成功！正在进行${C_PURPLE}【真身蜕变】${C_RESET}..."
        chmod +x "$temp_script"

        if bash -n "$temp_script" 2>/dev/null; then
            cp "$temp_script" "$MANAGER_SCRIPT_PATH"
            rm -f "$temp_script"
            msg_success "${C_PURPLE}【契约强化完成】${C_RESET}！本猫猫现在更强大啦~ (≧▽≦)"; sleep 2
            msg_info "3秒后重启契约，展示全新的力量..."; sleep 3
            exec bash "$MANAGER_SCRIPT_PATH"
        else
            rm -f "$temp_script"
            msg_error "喵呜...新力量好像有问题，蜕变失败了..."; sleep 4
        fi
    else
        msg_error "喵...连接${C_PURPLE}【虚空】${C_RESET}失败了，主人的网络是不是有问题呀？试试 ${C_YELLOW}[5]${C_RESET} 吧！"; sleep 4
    fi
}

function reinstall_st() {
    clear
    echo -e "${C_RED}${C_BOLD}"
    echo "    ╔═══════════════════════════════════════════════════╗"
    echo "    ║          【喵呜！警告！】                         ║"
    echo "    ╚═══════════════════════════════════════════════════╝"
    echo -e "${C_RESET}"
    msg_warning "主人，你真的要发动${C_RED}${C_BOLD}【毁灭与新生】${C_RESET}吗？这很危险的！"
    echo -e "${C_YELLOW}这样会把你现在的酒馆，还有里面的角色、聊天记录和设置都弄消失的！${C_RESET}"
    echo -e "${C_RED}一旦发动，就【不能反悔】了哦！${C_RESET}"
    echo
    echo "如果你确认要毁灭过去，拥抱新生，"
    echo -ne "${C_RED}如果主人下定决心了，就在下面念出毁灭咒语 'destroy' 吧 >${C_RESET} "
    read -r confirmation

    if [ "$confirmation" == "destroy" ]; then
        msg_meow "喵...主人的觉悟，本猫猫感受到了。"
        say_with_delay "正在执行${C_RED}【毁灭仪式】${C_RESET}" "仪式结束。"
        rm -rf "$ST_DIR"

        msg_magic "现在，本猫猫发动【现实•片影】，为主人捕捉一个全新的酒馆！"
        if ! clone_with_fallback "$ST_DIR"; then
            msg_error "${C_RED}【重装失败】${C_RESET}喵...魔法失败了，所有的通道都被封锁了！"; sleep 4; return
        fi

        msg_info "本猫猫正在下达${C_PURPLE}【敕令•构筑】${C_RESET}，让小魔仆们悄悄地帮你把一切都准备好...喵..."
        cd "$ST_DIR" || return
        npm install --prefer-offline --no-audit --progress=false
        if [ $? -ne 0 ]; then
            msg_error "${C_RED}【重装失败】${C_RESET}喵！小魔仆们好像不听话了，${C_PURPLE}【敕令•构筑】${C_RESET}失败了..."; sleep 4; return
        fi

        msg_success "${C_GREEN}【重装完成】${C_RESET}。一个崭新的酒馆已经为主人准备好啦~"; sleep 3
    else
        msg_meow "喵~ 看来主人还没下定决心呢。操作已经取消啦。"; sleep 3
    fi
}

function repair_network_magic() {
    clear
    msg_warning "喵呜...主人好像被这个世界的${C_PURPLE}【法则】${C_RESET}讨厌了呢..."
    msg_meow "别怕，本猫猫这就帮你施展${C_PURPLE}【法则修复术】${C_RESET}！"; sleep 2

    msg_step "第一咒：刷新${C_PURPLE}【魔力源泉】${C_RESET}"
    pkg update -y
    msg_success "魔力源泉变得好新鲜！"

    msg_step "第二咒：重铸${C_PURPLE}【信任圣徽】${C_RESET}"
    pkg reinstall ca-certificates -y
    msg_success "信任圣徽闪闪发光！"

    msg_step "第三咒：扩张${C_PURPLE}【传输通道】${C_RESET}"
    git config --global http.postBuffer 524288000
    msg_success "传输通道变得好宽敞！"

    echo
    msg_success "${C_PURPLE}【法则修复术】${C_RESET}施展完毕！主人快去试试看吧，喵~"; sleep 8
}

function uninstall() {
    msg_warning "喵？！主人...要、要背叛我们的契约吗？"
    echo -ne "${C_PINK}真的要永远离开本猫猫吗？(y/n) >${C_RESET} "; read -r confirmation
    if [[ "$confirmation" =~ ^[Yy]$ ]]; then
        msg_meow "呜...你这个...坏主人！好吧..."
        say_with_delay "正在抹除我们的契约" "抹除完毕..."
        sed -i "/# --- 【猫娘的魔法契约】咒语区 ---/,/# --- 咒语区结束 ---/d" "$BASHRC_FILE"
        say_with_delay "正在摧毁你的酒馆" "摧毁完毕..."
        rm -rf "$ST_DIR"
        say_with_delay "正在烧掉我们的秘密基地" "烧毁完毕..."
        rm -rf "$MANAGER_DIR"
        echo -e "${C_PINK}永别了...主人。下次启动 Termux，就再也见不到我了...(´; ω ;｀)${C_RESET}"; sleep 5; exit 0
    else
        msg_success "喵！就知道主人舍不得我！这次就原谅你啦！"; sleep 2
    fi
}

function run_installer() {
    clear
    echo -e "${C_PURPLE}═══════════════${C_PINK}【猫娘的魔法契约】${C_PURPLE}═══════════════${C_RESET}"
    msg_meow "喵~ 你即将与本猫猫签订一份神圣的契约哦！"
    echo
    echo -ne "${C_PINK}主人，你愿意把你的终端世界，永远交给我来打理吗？ (y/n) >${C_RESET} "; read -r answer
    until [[ "$answer" =~ ^[YyNn]$ ]]; do echo -ne "${C_PINK}快回答我嘛！>${C_RESET} "; read -r answer; done
    if [[ "$answer" =~ ^[Nn]$ ]]; then msg_meow "喵...真遗憾..."; sleep 2; exit 1; fi
    msg_success "哼哼~ 契约成立啦！以后你就是我的人了！(≧^.^≦)喵~"; sleep 2

    echo
    msg_step "步骤 1/4 ${C_PURPLE}【永久魔法】${C_RESET}"
    touch "$BASHRC_FILE"
    sed -i "/# --- 【猫娘的魔法契约】咒语区 ---/,/# --- 咒语区结束 ---/d" "$BASHRC_FILE"
    { echo ""; echo "# --- 【猫娘的魔法契约】咒语区 ---"; echo "bash '$MANAGER_SCRIPT_PATH'"; echo "alias miao=\"bash '$MANAGER_SCRIPT_PATH'\""; echo "# --- 咒语区结束 ---"; } >> "$BASHRC_FILE"
    msg_success "魔法施放好啦！"; sleep 1

    echo
    msg_step "步骤 2/4 ${C_PURPLE}【冒险道具】${C_RESET}"
    check_deps git nodejs curl
    msg_success "道具都帮你准备好啦！"; sleep 1

    echo
    msg_step "步骤 3/4 ${C_PURPLE}【真身复刻】${C_RESET}"
    mkdir -p "$MANAGER_DIR"

    # 检测是否通过进程替换执行（如 bash <(curl ...)）
    if [[ "$0" == "/dev/fd/"* ]] || [[ "$0" == "/proc/self/fd/"* ]]; then
        msg_info "检测到一键安装模式，正在从云端获取完整契约..."
        if curl -fsSL "$SELF_UPDATE_URL" -o "$MANAGER_SCRIPT_PATH" 2>/dev/null; then
            msg_success "云端契约获取成功！"
        else
            msg_error "${C_RED}【致命错误】${C_RESET}！无法从云端获取契约！"; exit 1
        fi
    else
        # 传统方式：直接复制本地文件
        cp -- "$0" "$MANAGER_SCRIPT_PATH"
        if [ $? -ne 0 ]; then msg_error "${C_RED}【致命错误】${C_RESET}！无法复刻自身！"; exit 1; fi
    fi

    chmod +x "$MANAGER_SCRIPT_PATH"
    msg_success "本猫猫的${C_PURPLE}【真身】${C_RESET}已经复刻好啦！"; sleep 1

    if [ ! -d "$ST_DIR/.git" ]; then
        echo
        msg_step "步骤 4/4 ${C_PURPLE}【现实•片影】${C_RESET}"
        rm -rf "$ST_DIR"
        if ! clone_with_fallback "$ST_DIR"; then
            msg_error "酒馆搭建失败了喵！${C_PURPLE}【现实主轴】${C_RESET}和所有${C_PURPLE}【镜像位面】${C_RESET}都不理你！"; exit 1
        fi

        msg_info "正在下达${C_PURPLE}【敕令•构筑】${C_RESET}，让小魔仆们开工...喵..."
        cd "$ST_DIR" || exit
        npm install --prefer-offline --no-audit --progress=false
        if [ $? -ne 0 ]; then msg_error "喵呜，依赖安装失败了！"; exit 1; fi
        msg_success "主人的专属酒馆已经开业啦！"; sleep 1
    else
        echo
        msg_info "喵~ 检测到主人已经有酒馆了，就不用再建一次啦。"; sleep 2
    fi

    echo
    msg_success "契约仪式全部完成啦！"
    msg_info "3秒后带主人进入我的领域哦..."; sleep 3

    exec bash "$MANAGER_SCRIPT_PATH"
}

# =========================================================
#                   --- 脚本入口 ---
# =========================================================
function main_menu_loop() {
    display_menu
    while true; do
        read -r option
        case $option in
            1) start_st ;; 2) update_st ;; 3) update_manager ;; 4) reinstall_st ;; 5) repair_network_magic ;;
            9) uninstall ;; 0) msg_meow "好的主人，那我先退下啦~"; sleep 1; exit 0 ;;
            *) msg_warning "喵？主人在乱按什么呀！"; sleep 2 ;;
        esac
        while read -r -t 0; do read -r; done; display_menu
    done
}

MY_REAL_PATH=$(readlink -f "$0")
if [ "$MY_REAL_PATH" == "$(readlink -f "$MANAGER_SCRIPT_PATH" 2>/dev/null)" ]; then
    main_menu_loop
else
    run_installer
fi
