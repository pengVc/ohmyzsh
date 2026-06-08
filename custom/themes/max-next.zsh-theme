# base on prefix t>heme for oh-my-zsh
# Tested on Linux, Unix and Windows under ANSI colors.
# Copyright: Skyler Lee, 2015

# Colors: black|red|blue|green|yellow|magenta|cyan|white
local black=$fg[black]
local red=$fg[red]
local blue=$fg[blue]
local green=$fg[green]
local yellow=$fg[yellow]
local magenta=$fg[magenta]
local cyan=$fg[cyan]
local white=$fg[white]
local gray="%F{8}"

local black_bold=$fg_bold[black]
local red_bold=$fg_bold[red]
local blue_bold=$fg_bold[blue]
local green_bold=$fg_bold[green]
local yellow_bold=$fg_bold[yellow]
local magenta_bold=$fg_bold[magenta]
local cyan_bold=$fg_bold[cyan]
local white_bold=$fg_bold[white]

local highlight_bg=$bg[red]

local top_prefix='╭─'
local bottom_prefix='╰─'
local bottom_prefix_arrow='➤'

# 项目根标识文件/目录，遇到时停止向上获取路径（可扩展，如添加 package.json）
local project_root_markers=(.git package.json)

# 计算字符串的可见字符长度（去除 ANSI 转义和 zsh 提示转义）
function visible_len {
    local zero='%([BSUbfksu]|([FB]|){*})'
    echo ${#${(S%%)1//$~zero/}}
}

# Machine name.
function get_box_name {
    if [ -f ~/.box-name ]; then
        cat ~/.box-name
    else
        echo $HOST
    fi
}

# User name.
function get_usr_name {
    local name="%n"
    if [[ "$USER" == 'root' ]]; then
        name="%{$highlight_bg%}%{$white_bold%}$name%{$reset_color%}"
    fi
    echo $name
}

# Directory info.
# 始终从项目根开始展示路径；若超出终端宽度则进一步截断并加 … 前缀
function get_current_dir {
    local dir="${PWD/#$HOME/~}"
    local parts=("${(@)${(@s:/:)dir}:#}")
    local total=${#parts}

    # 1. 查找项目根：从最深层向上，找到包含标识文件/目录的目录
    local project_root_idx=0
    local i=$total
    while [[ $i -gt 0 ]]; do
        local check_path="${(j:/:)parts[1,$i]}"
        check_path="${check_path/#\~/$HOME}"
        for marker in $project_root_markers; do
            if [[ -e "$check_path/$marker" ]]; then
                project_root_idx=$i
                break 2
            fi
        done
        i=$(( i - 1 ))
    done

    # 2. 从项目根开始截取路径
    if [[ $project_root_idx -gt 0 ]]; then
        local result="${(j:/:)parts[$project_root_idx,$total]}"
    else
        local result="$dir"
    fi

    # 3. 计算终端可用宽度
    local fixed="%{$blue%}# %{$reset_color%}$(get_git_prompt) %{$blue%}[$(get_time_stamp)]%{$reset_color%}"
    local fixed_len=$(visible_len "$fixed")
    local available=$(( $COLUMNS - $fixed_len ))

    # 4. 路径能放下就直接展示
    if [[ ${#result} -le $available ]]; then
        echo "$result"
        return
    fi

    # 5. 放不下：从最深层逐层向上拼接，直到占满可用宽度
    local trunc_parts=("${(@)${(@s:/:)result}:#}")
    local trunc_result="${trunc_parts[-1]}"
    local j=$(( ${#trunc_parts} - 1 ))
    while [[ $j -gt 0 ]]; do
        local candidate="${trunc_parts[$j]}/${trunc_result}"
        if [[ ${#candidate} -gt $available ]]; then
            break
        fi
        trunc_result="$candidate"
        j=$(( j - 1 ))
    done
    if [[ $j -gt 0 ]]; then
        trunc_result="…${trunc_result}"
    fi
    echo "$trunc_result"
}

# Git info.
ZSH_THEME_GIT_PROMPT_PREFIX="%{$blue_bold%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$green_bold%}  "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$red_bold%}  "

# Git status.
ZSH_THEME_GIT_PROMPT_ADDED="%{$green_bold%}+"
ZSH_THEME_GIT_PROMPT_DELETED="%{$red_bold%}-"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$magenta_bold%}*"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$blue_bold%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$cyan_bold%}="
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$yellow_bold%}?"

# Git sha.
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="[%{$yellow%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%}]"

function get_git_prompt {
    if [[ -n $(git rev-parse --is-inside-work-tree 2>/dev/null) ]]; then
        local git_status="$(git_prompt_status)"
        if [[ -n $git_status ]]; then
            git_status="[$git_status%{$reset_color%}]"
        fi
        local git_prompt=" <$(git_prompt_info)$git_status>"
        echo $git_prompt
    fi
}

function get_time_stamp {
    echo "%*"
}

function get_space {
    local str=$1$2
    local zero='%([BSUbfksu]|([FB]|){*})'
    local len=${#${(S%%)str//$~zero/}}
    local size=$(( $COLUMNS - $len - 1 ))
    local space=""
    while [[ $size -gt 0 ]]; do
        space="$space-"
        let size=$size-1
    done
    echo "%{$gray%}$space%{$reset_color%}"
}

# Prompt: # USER@MACHINE: DIRECTORY <BRANCH [STATUS]> --- (TIME_STAMP)
# > command
function get_prompt_header {
    local left_prompt="\
%{$gray%}$top_prefix \
%{$yellow_bold%}$(get_current_dir)%{$reset_color%}\
$(get_git_prompt) "
    local right_prompt=" %{$blue%}[$(get_time_stamp)]%{$reset_color%}"
    echo "$left_prompt$(get_space $left_prompt $right_prompt)$right_prompt"
}

function get_prompt_indicator {
    if [[ $? -eq 0 ]]; then
        echo "%{$gray%}$bottom_prefix%{$magenta_bold%}$bottom_prefix_arrow %>{$reset_color%}"
    else
        echo "%{$gray%}$bottom_prefix%{$red_bold%}$bottom_prefix_arrow %>{$reset_color%}"
    fi
}

setopt prompt_subst

PROMPT='$(get_prompt_header)
$(get_prompt_indicator)'
# RPROMPT='$(git_prompt_short_sha) '

# Workaround for async git handler
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/git.zsh#L64
local _style
if zstyle -t ':omz:alpha:lib:git' async-prompt \
  || { is-at-least 5.0.6 && zstyle -T ':omz:alpha:lib:git' async-prompt } \
  || { zstyle -s ':omz:alpha:lib:git' async-prompt _style && [[ $_style == "force" ]] }; then
    _omz_register_handler _omz_git_prompt_info
    _omz_register_handler _omz_git_prompt_status
fi

keep_bottom_precmd () {
  # 想留 5 行空白
  printf '\n\n\n\n\n\e[5A'
}

add-zsh-hook precmd keep_bottom_precmd
