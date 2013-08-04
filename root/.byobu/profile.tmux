#source $BYOBU_PREFIX/share/byobu/profiles/tmux

# Initialize environment, clean up
set-environment -g BYOBU_BACKEND tmux
new-window -d byobu-janitor
set -s escape-time 0

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
set-window-option -g window-status-alert-bg $BYOBU_DARK
set-window-option -g window-status-alert-fg $BYOBU_LIGHT
set-window-option -g window-status-alert-attr bold
set-window-option -g window-status-activity-bg $BYOBU_DARK
set-window-option -g window-status-activity-fg $BYOBU_LIGHT
set-window-option -g window-status-activity-attr bold
set-window-option -g automatic-rename off
set-window-option -g aggressive-resize on
set-window-option -g monitor-activity on

set -g default-terminal "screen-256color"
setw -g xterm-keys on

# The following helps with Shift-PageUp/Shift-PageDown
set -g terminal-overrides "xterm*:screen*:t_kP=\e[5;*~:t_kN=\e[6;*~:kLFT5=\eOD:kRIT5=\eOC:kUP5=\eOA:kDN5=\eOB:smkx@:rmkx@:smcup@:rmcup@"
#set -g terminal-overrides 'xterm*:smcup@:rmcup@'

# Must set default-command to $SHELL, in order to not source ~/.profile
# BUG: Should *not* hardcode /bin/bash here
set -g default-command /bin/zsh

set -g status-bg $BYOBU_DARK
set -g status-fg $BYOBU_LIGHT
set -g status-interval 2
set -g status-left-length 256
set -g status-right-length 256
#set -g status-left '#(byobu-status tmux_left)'
#set -g status-right '#(byobu-status tmux_right)'
set -g status-left '#(/shared/root/tmux-powerline/powerline.sh left)'
set -g status-right '#(/shared/root/tmux-powerline/powerline.sh right)'
set -g message-bg $BYOBU_ACCENT
set -g message-fg white

# add powerline
#source /shared/root/powerline/powerline/bindings/tmux/powerline.conf

#set-option -g status on
#set-option -g status-interval 2
#set-option -g status-utf8 on
#set-option -g status-justify "centre"
#set-option -g status-left-length 60
#set-option -g status-right-length 90
#set-option -g status-left "#(/shared/root/tmux-powerline/powerline.sh left)"
#set-option -g status-right "#(/shared/root/path/to/tmux-powerline/powerline.sh right)"
#set-window-option -g window-status-current-format "#[fg=colour235, bg=colour27]то#[fg=colour255, bg=colour27] #I то #W #[fg=colour27, bg=colour235]то"



