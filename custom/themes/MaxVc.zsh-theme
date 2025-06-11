# Fork from: awesomepanda.zsh-theme
local ret_status="%(?:%{$fg_bold[green]%} ➜ :%{$fg_bold[red]%} ➜ %s)"

# 动态获取 Conda 环境信息（每次提示符更新时执行）
function conda_prompt_info() {
  if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    echo -n "%{$fg[yellow]%}(🐍${CONDA_DEFAULT_ENV})%{$reset_color%}" # 颜色可自定义
  fi
}

function precmd_dashed_line() {
  local cols=$COLUMNS
  local dash_line=$(printf '-%.0s' {1..$cols})
  local color_start=${DASH_COLOR:-%{%F{238}%}}
  # local color_start=${DASH_COLOR:-%{$fg[blue]%}}
  local color_reset=%{$reset_color%}
  print -P "${color_start}${dash_line}${color_reset}"
}

# 检查 precmd_dashed_line 是否已经注册到 precmd_functions 中
if [[ ! " ${precmd_functions[@]} " =~ " precmd_dashed_line " ]]; then
  precmd_functions+=(precmd_dashed_line)
fi

# 注：这里一定要是单引号，双引号会导致 conda_prompt_info 函数无法执行
PROMPT='$(conda_prompt_info)'
PROMPT+='${ret_status}%{$fg_bold[green]%}%{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}$(svn_prompt_info)%{$reset_color%}'
RPROMPT='[%*]'

ZSH_THEME_GIT_PROMPT_PREFIX="git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%})%{$fg[yellow]%} ✗ %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}) "

ZSH_PROMPT_BASE_COLOR="%{$fg_bold[blue]%}"
ZSH_THEME_REPO_NAME_COLOR="%{$fg_bold[red]%}"

ZSH_THEME_SVN_PROMPT_PREFIX="svn:("
ZSH_THEME_SVN_PROMPT_SUFFIX=")"
ZSH_THEME_SVN_PROMPT_DIRTY="%{$fg[red]%} ✘ %{$reset_color%}"
ZSH_THEME_SVN_PROMPT_CLEAN=" "
