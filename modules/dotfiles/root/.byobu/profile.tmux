#source $BYOBU_PREFIX/share/byobu/profiles/tmux

# Initialize environment, clean up
set-environment -g BYOBU_BACKEND tmux
new-session -d byobu-janitor
set -s escape-time 0

# Fix for mosh printing A B C D on arrow keys when using xterm instead of screen
set-option -s escape-time 1000

# Change to Screen's ctrl-a escape sequence
source /usr/share/doc/tmux/examples/screen-keys.conf

#rebind ^Q instead ^A
unbind ^A
set -g prefix ^Q
bind q send-prefix

set-option -g set-titles on
set-option -g set-titles-string '#(whoami)@#H - byobu (#S)'
set-option -g pane-active-border-bg $BYOBU_ACCENT
set-option -g pane-active-border-fg $BYOBU_ACCENT
set-option -g pane-border-fg $BYOBU_LIGHT
set-option -g history-limit 10000
set-option -g display-panes-time 150
set-option -g display-panes-colour $BYOBU_ACCENT
set-option -g display-panes-active-colour $BYOBU_HIGHLIGHT
set-option -g clock-mode-colour $BYOBU_ACCENT
set-option -g clock-mode-style 24
set-option -g mode-keys vi
set-option -g mode-bg $BYOBU_ACCENT
set-option -g mode-fg $BYOBU_LIGHT

set-window-option -g window-status-attr default
set-window-option -g window-status-bg $BYOBU_DARK
set-window-option -g window-status-fg $BYOBU_LIGHT
set-window-option -g window-status-current-attr reverse
set-window-option -g window-status-current-bg $BYOBU_DARK
set-window-option -g window-status-current-fg $BYOBU_LIGHT
#set-window-option -g window-status-alert-bg $BYOBU_DARK
#set-window-option -g window-status-alert-fg $BYOBU_LIGHT
#set-window-option -g window-status-alert-attr bold
set-window-option -g window-status-activity-bg $BYOBU_DARK
set-window-option -g window-status-activity-fg $BYOBU_LIGHT
set-window-option -g window-status-activity-attr bold
set-window-option -g automatic-rename off
set-window-option -g aggressive-resize on
set-window-option -g monitor-activity on

set -g base-index 1
set-window-option -g pane-base-index 1

# mouse
setw -g mode-mouse on
set -g mouse-resize-pane on
set -g mouse-select-pane on
set -g mouse-select-window on

set -g default-terminal "xterm-screen-256color"
setw -g xterm-keys on

# Fix putty/pietty function key problem
set -g terminal-overrides "*:kf1=\e[11~:kf2=\e[12~:kf3=\e[13~:kf4=\e[14~:kf5=\e[15~:kf6=\e[17~:kf7=\e[18~:kf8=\e[19~"

# (doesn't work) Fix for mosh printing random characters when using mouse
#set -g mouse-utf8 off
set -g mouse-utf8 on

setw -g utf8 on

# The following helps with Shift-PageUp/Shift-PageDown
#set -g terminal-overrides "xterm*:screen*:t_kP=\e[5;*~:t_kN=\e[6;*~:kLFT5=\eOD:kRIT5=\eOC:kUP5=\eOA:kDN5=\eOB:smkx@:rmkx@:smcup@:rmcup@"
#set -g terminal-overrides 'xterm*:smcup@:rmcup@'

# Must set default-command to $SHELL, in order to not source ~/.profile
# BUG: Should *not* hardcode /bin/bash here
set -g default-command /bin/zsh

set -g status-bg $BYOBU_DARK
set -g status-fg $BYOBU_LIGHT
set -g status-interval 2
set -g status-left-length 256
set -g status-right-length 256
set -g status-left '#(byobu-status tmux_left)'
set -g status-right '#(byobu-status tmux_right)'
#set -g status-left '#(/shared/modules/dotfiles/root/.addons/tmux-powerline/powerline.sh left)'
#set -g status-right '#(/shared/modules/dotfiles/root/.addons/tmux-powerline/powerline.sh right)'
set -g message-bg $BYOBU_ACCENT
set -g message-fg white

# add powerline
#source /shared/modules/dotfiles/root/.addons/powerline/powerline/bindings/tmux/powerline.conf

#set-option -g status on
#set-option -g status-interval 2
#set-option -g status-utf8 on
#set-option -g status-justify "centre"
#set-option -g status-left-length 60
#set-option -g status-right-length 90
#set-option -g status-left "#(/shared/modules/dotfiles/root/.addons/tmux-powerline/powerline.sh left)"
#set-option -g status-right "#(/shared/root/path/to/tmux-powerline/powerline.sh right)"
#set-window-option -g window-status-current-format "#[fg=colour235, bg=colour27]то#[fg=colour255, bg=colour27] #I то #W #[fg=colour27, bg=colour235]то"

