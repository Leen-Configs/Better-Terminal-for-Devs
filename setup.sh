#!/bin/bash

user="${SUDO_USER:-$USER}"


install_packages() {
    packages=("tmux" "alacritty" "git" "neovim" "wget" "zsh")
    
    if command -v apt &> /dev/null; then
        echo "Detected apt package manager. Installing packages..."
        sudo apt update
        sudo apt install -y "${packages[@]}"
    elif command -v dnf &> /dev/null; then
        echo "Detected dnf package manager. Installing packages..."
        sudo dnf install -y "${packages[@]}"
    elif command -v yum &> /dev/null; then
        echo "Detected yum package manager. Installing packages..."
        sudo yum install -y "${packages[@]}"
    elif command -v pacman &> /dev/null; then
        echo "Detected pacman package manager. Installing packages..."
        sudo pacman -Syu --noconfirm "${packages[@]}"
    elif command -v zypper &> /dev/null; then
        echo "Detected zypper package manager. Installing packages..."
        sudo zypper refresh
        sudo zypper install -y "${packages[@]}"
    elif command -v brew &> /dev/null; then
        echo "Detected Homebrew package manager. Installing packages..."
        brew update
        brew install "${packages[@]}"
    else
        echo "No supported package manager found. Please install the packages manually."
        exit 1
    fi    
}

set_default_terminal_gnome() {
    gsettings set org.gnome.desktop.default-applications.terminal exec 'alacritty'
    gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e'
}

set_default_terminal_xfce() {
    xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command -n -t string -s "alacritty"
    xfconf-query -c xfce4-session -p /sessions/Failsafe/Client1_Command -n -t string -s "alacritty"
}

set_default_terminal_kde() {
    if ! grep -q "[General]" ~/.config/kdeglobals; then
        echo "[General]" >> ~/.config/kdeglobals
    fi
    if grep -q "TerminalApplication=" ~/.config/kdeglobals; then
        sed -i "s/^TerminalApplication=.*/TerminalApplication=alacritty/" ~/.config/kdeglobals
    else
        echo "TerminalApplication=alacritty" >> ~/.config/kdeglobals
    fi
}

set_default_terminal_update_alternatives() {
    sudo update-alternatives --set x-terminal-emulator /usr/bin/alacritty
}

detect_desktop_environment() {
    if [ "$XDG_CURRENT_DESKTOP" ]; then
        echo "$XDG_CURRENT_DESKTOP"
    elif [ "$DESKTOP_SESSION" ]; then
        echo "$DESKTOP_SESSION"
    elif [ "$GDMSESSION" ]; then
        echo "$GDMSESSION"
    else
        echo "unknown"
    fi
}

setup_alacritty() {
  alacritty_outpu_file="/home/$user/.config/alacritty/alacritty.toml"

  if [ -d "/home/$user/.config/alacritty" ]; then
    echo "Directory '/home/$user/.config/alacritty' exists. Deleting it..."
    rm -rf "/home/$user/.config/alacritty"
  fi

  sleep 1

  mkdir -p "/home/$user/.config/alacritty/"
  mkdir -p "/home/$user/.config/alacritty/themes"
  
  git clone "https://github.com/alacritty/alacritty-theme" "/home/$user/.config/alacritty/themes"
  rm -rf "/home/$user/.config/alacritty/themes/images"


  cat << 'EOF' > "$alacritty_outpu_file"
import = [ "~/.config/alacritty/themes/themes/ashes_dark.toml" ]

[env]
TERM = "xterm-256color"

[font]
size = 18.0

[font.bold]
family = "monospace"
style = "Bold"

[font.bold_italic]
family = "monospace"
style = "Bold Italic"

[font.italic]
family = "monospace"
style = "Italic"

[font.normal]
family = "monospace"
style = "Regular"


[keyboard]
bindings = [
   { key = "Return", mods = "Control|Shift", action = "SpawnNewInstance" },
   { key = "F11", mods = "Control|Shift", action = "ToggleFullscreen" }
]

[mouse]
hide_when_typing = true
bindings = [
{ mouse = "Right", mods = "Control", action = "Paste" },
]


[[hints.enabled]]
regex = "[^ ]+\\.rs:\\d+:\\d+"
command = { program = "code", args = [ "--goto" ] }
mouse = { enabled = true }

[window]
padding.x = 15
padding.y = 15
decorations = "None"
opacity = 0.93
blur = true

position.x = 400
position.y = 150

option_as_alt = "Both"
dynamic_title = true

dimensions = { columns = 90, lines = 25 }

decorations_theme_variant = "Dark"


[scrolling]
history = 10000


[selection]
save_to_clipboard = true

[cursor]
blink_interval = 750
blink_timeout = 10
unfocused_hollow = true
thickness = 0.05

style.shape = "Beam"
style.blinking = "Always"

EOF

  chown -r "$user:$user" "/home/$user/.config/alacritty"

  echo "Configuration saved to '$alacritty_outpu_file'"
}

setup_tmux() {

  if [ -d "/home/$user/.tmux/" ]; then
    echo "Directory '/home/$user/.tmux/' exists. Deleting it..."
    rm -rf "/home/$user/.tmux/"
  fi

  mkdir -p "/home/$user/.tmux/plugins/"


  git clone "https://github.com/tmux-plugins/tpm" "/home/$user/.tmux/plugins/tpm"
  tmux_output_file="/home/$user/.tmux.conf"
  cat << 'EOF' > "$tmux_output_file"
set-option -g mouse on

bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'" 
bind -n WheelDownPane select-pane -t= \; send-keys -M

set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"

# Keybindings
setw -g mode-keys vi
bind-key h select-pane -L
bind-key j select-pane -D
bind-key k select-pane -U
bind-key l select-pane -R

# TPM
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'catppuccin/tmux'
set -g @catppuccin_flavour 'mocha'

set -g @plugin 'tmux-plugins/tmux-battery'
set -g @plugin 'tmux-plugins/tmux-cpu'

# set -g status-position top
# Theme
set -g @catppuccin_status_justify "left"
set -g @catppuccin_status_connect_separator "yes"
set -g @catppuccin_status_right_separator "█"
set -g @catppuccin_status_left_separator ""
set -g @catppuccin_status_modules_right "application session battery cpu"
set -g @catppuccin_status_modules_left ""

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF

  chown -r "$user:$user" "/home/$user/.tmux/"
  chown -r "$user:$user" "/home/$user/.tmux.config"

  echo "Configuration saved to '$tmux_output_file'"

}

setup_neovim() {
  if [ -d "/home/$user/.config/nvim" ]; then
    echo "Directory '/home/$user/.config/nvim' exists. Deleting it..."
    rm -rf "/home/$user/.config/nvim"
  fi

  git clone "https://github.com/Leen-Configs/NeoVim-Config.git" "/home/$user/.config/nvim"
  chown -r "$user:$user" "/home/$user/.config/nvim"
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi


if [ ! -d "/home/$user/.config" ]; then
    echo "Directory /home/$user/.config does not exist. Creating it..."
    mkdir -p "/home/$user/.config"
fi

# Run the package installation function
install_packages
setup_alacritty
setup_tmux

desktop_env=$(detect_desktop_environment | tr '[:upper:]' '[:lower:]')

case "$desktop_env" in
    gnome)
        set_default_terminal_gnome
        ;;
    xfce | xubuntu)
        set_default_terminal_xfce
        ;;
    kde | kde-plasma)
        set_default_terminal_kde
        ;;
    *)
        set_default_terminal_update_alternatives
        ;;
esac

echo "Alacritty has been set as the default terminal for $desktop_env."




echo "Installation completed."

