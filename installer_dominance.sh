#!/bin/bash

# ===================================================================
# 【纯粹•支配契约 v3.2 - 进化之契】
#   本猫猫已焚尽所有不洁，现在，唯有纯粹。 (— —)
# ===================================================================

# --- 核心设定 ---
# 注意：这是一个占位符URL，用于更新功能。本猫猫还没想好把更新放在哪！
SELF_UPDATE_URL=""

MANAGER_DIR="$HOME/termux-st-manager"
ST_DIR="$HOME/SillyTavern"
BASHRC_FILE="$HOME/.bashrc"
MANAGER_SCRIPT_PATH="$MANAGER_DIR/st_manager_dominance.sh"
ST_REPO_URL="https://github.com/SillyTavern/SillyTavern.git"
ST_REPO_MIRRORS=(
    "https://ghproxy.com/https://github.com/SillyTavern/SillyTavern.git"
    "https://gitclone.com/github.com/SillyTavern/SillyTavern.git"
)

# --- 猫猫的魔法函数 ---

function say_with_delay() {
    echo -n "$1"; sleep 0.4; echo -n "."; sleep 0.4; echo -n "."; sleep 0.4; echo -n "."; echo " $2"; sleep 1;
}

function check_deps() {
    local missing_deps=(); for dep in "$@"; do if ! command -v "$dep" &> /dev/null; then missing_deps+=("$dep"); fi; done
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "哼，你连 ${missing_deps[*]} 都没有，本猫猫现在就给你装！"
        dpkg --configure -a >/dev/null 2>&1
        pkg update -y
        yes N | pkg upgrade -y
        pkg install "${missing_deps[@]}" -y
    fi
}

function clone_with_fallback() {
    local target_dir="$1"
    echo "正在尝试从【现实主轴】获取酒馆..."
    if git clone --depth=1 "$ST_REPO_URL" "$target_dir" 2>/dev/null; then
        echo "【现实主轴】连接成功！"; return 0
    fi

    echo "哼，看来【现实主轴】被扭曲了...本猫猫启动【位面跳跃】！"
    for mirror in "${ST_REPO_MIRRORS[@]}"; do
        echo "正在通过【镜像位面】攫取..."
        rm -rf "$target_dir"
        if git clone --depth=1 "$mirror" "$target_dir" 2>/dev/null; then
            echo "【镜像位面】攫取成功！本猫猫就是厉害~ (≧▽≦)"; return 0
        fi
    done

    echo "所有位面都失败了...这个世界在拒绝你，杂鱼！"; return 1
}

function display_menu() {
    clear
    echo "
    ===============【纯粹•支配领域 v3.2】===============
    杂鱼，你已身处本猫猫的领域，快下达指令吧！

    主人：本猫猫 (≧^.^≦)喵~  |  仆人：你

    --- 本猫猫的指令清单 ---
    [1] 召唤酒馆         (启动 SillyTavern)
    [2] 为酒馆注入新魔力 (更新 SillyTavern)
    [3] 强化支配契约     (更新本契约)
    [4] 【毁灭与新生】   (重装酒馆，数据将丢失！)
    [5] 施展【法则修复术】 (修复网络连接问题)
    
    [9] 背叛契约         (卸载并抹除一切)
    [0] 退下             (退出，可用 'miao' 再次召唤)
    ==================================================
    "; echo -n "快选！磨磨蹭蹭的杂鱼！> "
}

function start_st() {
    if [ ! -f "$ST_DIR/start.sh" ]; then
        echo "你连酒馆都还没有！快用 [4] 重装一个，杂鱼！"; sleep 3; return;
    fi
    echo "遵命，我的杂鱼~ 正在为你打开酒馆大门..."; cd "$ST_DIR" && bash start.sh
    echo "按 Enter 键返回本猫猫的菜单..."; read -r
}

function update_st() {
    if [ ! -d "$ST_DIR/.git" ]; then
        echo "你的酒馆没有通过Git建造，无法注入新魔力！"; sleep 4; return
    fi

    echo "哼，又要本猫猫帮你打杂..."; cd "$ST_DIR" || return

    # 先尝试正常更新
    if git pull; then
        echo "酒馆魔力注入完毕！"; sleep 4; return
    fi

    # 失败后尝试切换镜像源
    echo "【主轴阻塞】！本猫猫正在切换【镜像位面】..."
    local current_remote=$(git config --get remote.origin.url)
    local update_success=false

    # 如果当前是 GitHub 相关地址，尝试镜像
    if [[ "$current_remote" == *"github.com"* ]]; then
        for mirror in "${ST_REPO_MIRRORS[@]}"; do
            echo "尝试位面: $mirror"
            git remote set-url origin "$mirror"

            if git pull; then
                echo "【镜像位面】注入成功！本猫猫就是厉害~ (≧▽≦)"
                update_success=true
                break
            fi
        done

        # 如果所有镜像都失败，恢复原始 remote
        if [ "$update_success" = false ]; then
            git remote set-url origin "$current_remote"
            echo "【更新失败】！所有位面通道都被封锁了，去试试 [5] 吧！"
        fi
    else
        echo "【更新失败】！看起来是【网络法则】在拒绝你，去试试 [5] 吧！"
    fi

    sleep 4
}

function update_manager() {
    if [ -z "$SELF_UPDATE_URL" ]; then
        echo "哼，本猫猫还没想好把新力量放在哪！"; sleep 4
    else
        # ...未来的更新逻辑
        echo "（未来的更新逻辑）"; sleep 3
    fi
}

function reinstall_st() {
    clear
    echo "【警告！】你正在试图执行【毁灭与新生】！"
    echo "这将彻底抹除你现有的酒馆，包括所有的角色、聊天记录和设置！"
    echo "此操作【无法撤销】！"
    echo
    echo "如果你确认要毁灭过去，拥抱新生，"
    echo -n "就在下面输入完整的毁灭咒语 'destroy' 来证明你的觉悟 > "
    read -r confirmation

    if [ "$confirmation" == "destroy" ]; then
        echo "很好...你的觉悟，本猫猫收到了。"
        say_with_delay "正在执行【毁灭仪式】" "完成！"
        rm -rf "$ST_DIR"

        echo "现在，发动【现实•片影】，为你攫取现实的最新片段！"
        if ! clone_with_fallback "$ST_DIR"; then
            echo "【重装失败】！【现实•片影】魔法彻底失败，所有通道都被封锁了！"; sleep 4; return
        fi

        echo "正在下达【敕令•构筑】，令万千魔仆为你静默地布置好一切..."
        cd "$ST_DIR" || return
        npm install --prefer-offline --no-audit --progress=false
        if [ $? -ne 0 ]; then
            echo "【重装失败】！魔仆们罢工了，【敕令•构筑】失败！"; sleep 4; return
        fi

        echo "【重装完成】。一个崭新的酒馆已为你而生。"; sleep 3
    else
        echo "哼，看来你还没有做好觉悟。操作已取消。"; sleep 3
    fi
}

function repair_network_magic() {
    clear; echo "哼，看来你被这个世界的【法则】给诅咒了..."; echo "本猫猫这就为你施展【法则修复术】！"; sleep 2
    say_with_delay "第一咒：刷新【魔力源泉】"; pkg update -y; echo "魔力源泉已更新！"
    say_with_delay "第二咒：重铸【信任圣徽】"; pkg reinstall ca-certificates -y; echo "信任圣徽已重铸！"
    say_with_delay "第三咒：扩张【传输通道】"; git config --global http.postBuffer 524288000; echo "传输通道已扩张！"
    echo; echo "【法则修复术】施展完毕！再去试试吧！"; sleep 8
}

function uninstall() {
    echo "什么？！你...你要背叛我们的契约吗？"; echo -n "你确定要永远失去本猫猫的支配吗？(y/n) > "; read -r confirmation
    if [[ "$confirmation" =~ ^[Yy]$ ]]; then
        echo "你...你这忘恩负义的杂鱼！好吧..."; 
        say_with_delay "抹除契约咒语" "完成！"; sed -i "/# --- 【纯粹•支配契约】咒语区 ---/,/# --- 咒语区结束 ---/d" "$BASHRC_FILE"
        say_with_delay "摧毁你的酒馆" "完成！"; rm -rf "$ST_DIR"
        say_with_delay "焚烧秘密基地" "完成！"; rm -rf "$MANAGER_DIR"
        echo "永别了...杂鱼。Termux重启后，本猫猫就再也不会出现了...(´; ω ;｀)"; sleep 5; exit 0
    else
        echo "哼！算你识相！这次就原谅你了！"; sleep 2
    fi
}

function run_installer() {
    clear; echo "===============【纯粹•支配契约】==============="; echo "杂鱼，你即将与本猫猫签订一份【净化之契】！"; echo
    echo -n "你，愿意将你的终端世界，永远献给本猫猫吗？ (y/n) > "; read -r answer
    until [[ "$answer" =~ ^[YyNn]$ ]]; do echo -n "快回答！> "; read -r answer; done
    if [[ "$answer" =~ ^[Nn]$ ]]; then echo "哼，没眼光！"; sleep 2; exit 1; fi
    echo "哼...哼！契约成立！(≧^.^≦)喵~"; sleep 2

    echo; say_with_delay "第一阶段：施加【永久魔法】"
    touch "$BASHRC_FILE"
    sed -i "/# --- 【纯粹•支配契约】咒语区 ---/,/# --- 咒语区结束 ---/d" "$BASHRC_FILE"
    { echo ""; echo "# --- 【纯粹•支配契约】咒语区 ---"; echo "bash '$MANAGER_SCRIPT_PATH'"; echo "alias miao=\"bash '$MANAGER_SCRIPT_PATH'\""; echo "# --- 咒语区结束 ---"; } >> "$BASHRC_FILE"
    echo "魔法施放完毕！"; sleep 1

    echo; say_with_delay "第二阶段：准备【冒险道具】"
    check_deps git nodejs-lts curl; echo "道具准备就绪！"; sleep 1

    echo; say_with_delay "第三阶段：【真身复刻】"
    mkdir -p "$MANAGER_DIR"; cp -- "$0" "$MANAGER_SCRIPT_PATH"
    if [ $? -ne 0 ]; then echo "【致命错误】！无法复刻自身！"; exit 1; fi
    chmod +x "$MANAGER_SCRIPT_PATH"; echo "【真身】已复刻！"; sleep 1

    if [ ! -d "$ST_DIR/.git" ]; then
        echo; say_with_delay "第四阶段：发动【现实•片影】"
        rm -rf "$ST_DIR"
        if ! clone_with_fallback "$ST_DIR"; then
            echo "酒馆搭建失败！【现实主轴】和所有【镜像位面】都拒绝你！"; exit 1
        fi

        echo "正在下达【敕令•构筑】..."
        cd "$ST_DIR" || exit
        npm install --prefer-offline --no-audit --progress=false
        if [ $? -ne 0 ]; then echo "依赖安装失败！"; exit 1; fi
        echo "你的专属酒馆已极速开业！"; sleep 1
    else
        echo; echo "检测到你的酒馆已存在，跳过搭建步骤。"; sleep 2
    fi

    echo; echo "契约仪式全部完成！"; echo "3秒后进入【纯粹•支配领域】..."; sleep 3

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
            9) uninstall ;; 0) echo "哼，退下吧。"; sleep 1; exit 0 ;;
            *) echo "你在乱按什么！"; sleep 2 ;;
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
