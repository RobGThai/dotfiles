autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_dirty() {
  if $(! $git status -s &> /dev/null)
  then
    echo ""
  else
    if [[ $($git status --porcelain) == "" ]]
    then
      echo "on %{$fg_bold[green]%}$(git_prompt_info)%{$reset_color%}"
    else
      echo "on %{$fg_bold[red]%}$(git_prompt_info)%{$reset_color%}"
    fi
  fi
}

git_prompt_info () {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
 echo "${ref#refs/heads/}"
}

unpushed () {
  $git cherry -v @{upstream} 2>/dev/null
}

need_push () {
  if [[ $(unpushed) == "" ]]
  then
    echo " "
  else
    echo " with %{$fg_bold[magenta]%}unpushed%{$reset_color%} "
  fi
}

ruby_version() {
  if (( $+commands[rbenv] ))
  then
    echo "$(rbenv version | awk '{print $1}')"
  fi

  if (( $+commands[rvm-prompt] ))
  then
    echo "$(rvm-prompt | awk '{print $1}')"
  fi
}

rb_prompt() {
  if ! [[ -z "$(ruby_version)" ]]
  then
    echo "%{$fg_bold[yellow]%}$(ruby_version)%{$reset_color%} "
  else
    echo ""
  fi
}

directory_name() {
  echo "%{$fg_bold[cyan]%}%1/%\/%{$reset_color%}"
}

dls () {
 # directory LS
 echo `ls -l | grep "^d" | awk '{ print $9 }' | tr -d "/"`
}

current_env() {
  if ! [[ -z "$VIRTUAL_ENV" ]] then

    # Supported color may be tested using this loop.
    # for COLOR in {0..255}
    # do
    #     for STYLE in "38;5"
    #     do
    #         TAG="\033[${STYLE};${COLOR}m"
    #         STR="${STYLE};${COLOR}"
    #         echo -ne "${TAG}${STR}${NONE}  "
    #     done
    #     echo
    # done

    env_color="\033[38;5;238m"
    echo "${env_color}Working on `basename \"$VIRTUAL_ENV\"`%{$reset_color%} "
  fi
}

export PROMPT=$'\n$(current_env)$(rb_prompt)in $(directory_name) $(git_dirty)$(need_push)\n› '

set_prompt () {
  export RPROMPT="%{$fg_bold[cyan]%}%{$reset_color%}"
}

# Support for bash
# PROMPT_COMMAND='prompt'
#
# function prompt()
# {
#     if [ "$PWD" != "$MYOLDPWD" ]; then
#         MYOLDPWD="$PWD"
#         test -e .venv && workon `cat .venv`
#     fi
# }

has_virtualenv() {
    if [ -e .venv ]; then
        workon `cat .venv`
    fi
}

venv_cd () {
    cd "$@" && has_virtualenv
}

# deactivate when leave
alias cd="venv_cd"

precmd() {
  title "zsh" "%m" "%55<...<%~"
  # eval "$PROMPT_COMMAND"
  set_prompt
}
