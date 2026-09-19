# Powerlevel10k no estilo lean do design Stratus (artboard "Terminal" do canvas):
#
#   ~/10-19_dev/13_infra/13.01_dotfiles on main !2 ✘ 1 took 2s
#   ❯
#
# Tokens em 11.06_visual-identity/design-system.md
# #6BA3E8 accent.primary · #8B6FBE accent.secondary · #45C4C4 accent.highlight
# #7A90A8 text.secondary · #4A5A70 text.muted
# #7ABF8A status.success · #E0B84A status.warning · #CC6070 status.error
# A config anterior (wizard rainbow) está em p10k.zsh.bak-rainbow.

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  local accent='#6BA3E8' accent2='#8B6FBE' highlight='#45C4C4'
  local dim='#7A90A8' muted='#4A5A70'
  local success='#7ABF8A' warning='#E0B84A' error='#CC6070'

  # ─── Layout ────────────────────────────────────────────────────────────────
  # Status e tempo ficam na mesma linha do caminho, como no design; os ambientes
  # (venv, jobs) só aparecem quando existem
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir vcs status command_execution_time background_jobs virtualenv
    newline
    prompt_char
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # Sem fundo nem separadores: só cor no texto
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_{PREFIX,SUFFIX}=

  # ─── Caminho ───────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$accent
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$accent
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$accent
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=false
  # Caminho inteiro; só encurta (pelo menor prefixo único) acima de 80 colunas
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80

  # ─── Git: "on main !2" ─────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_VCS_PREFIX="%F{$dim}on "
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((stratus_git_formatter(1)))+${stratus_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((stratus_git_formatter(0)))+${stratus_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  # Branch em accent.secondary; contadores no formato do git status curto:
  # ⇣⇡ atrás/à frente, +staged (success), !modificados (warning), ?novos, ~conflitos
  function stratus_git_formatter() {
    emulate -L zsh
    if [[ -n $P9K_CONTENT ]]; then
      typeset -g stratus_git_format=$P9K_CONTENT
      return
    fi
    # Roda a cada prompt, depois que a função de config já terminou: cores locais aqui
    local accent2='#8B6FBE' dim='#7A90A8' muted='#4A5A70'
    local success='#7ABF8A' warning='#E0B84A' error='#CC6070'
    local branch_color=$accent2 count_color=$warning
    (( $1 )) || { branch_color=$muted; count_color=$muted; }

    local res="%F{$branch_color}${VCS_STATUS_LOCAL_BRANCH:-@${VCS_STATUS_COMMIT[1,8]}}"
    (( VCS_STATUS_COMMITS_BEHIND )) && res+=" %F{$dim}⇣${VCS_STATUS_COMMITS_BEHIND}"
    (( VCS_STATUS_COMMITS_AHEAD  )) && res+=" %F{$dim}⇡${VCS_STATUS_COMMITS_AHEAD}"
    (( VCS_STATUS_NUM_CONFLICTED )) && res+=" %F{$error}~${VCS_STATUS_NUM_CONFLICTED}"
    (( VCS_STATUS_NUM_STAGED     )) && res+=" %F{$success}+${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" %F{$count_color}!${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" %F{$dim}?${VCS_STATUS_NUM_UNTRACKED}"
    typeset -g stratus_git_format=$res
  }
  functions -M stratus_git_formatter 2>/dev/null

  # ─── Resultado do último comando: "✘ 1" e "took 2s" ────────────────────────
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=false
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_SIGNAL,ERROR_PIPE}_FOREGROUND=$error
  typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_SIGNAL,ERROR_PIPE}_VISUAL_IDENTIFIER_EXPANSION='✘'

  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$muted
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX="%F{$muted}took "

  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=$dim
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=true
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$dim
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false

  # ─── ❯ em accent.highlight; status.error depois de falha ───────────────────
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$highlight
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$error
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  # ─── Comportamento ─────────────────────────────────────────────────────────
  # Prompts anteriores ficam inteiros, como no design (o transient os reduzia a ❯)
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
