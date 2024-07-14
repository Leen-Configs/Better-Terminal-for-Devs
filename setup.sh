#!/bin/bash

user="${SUDO_USER:-$USER}"

rm_if_exists() {
  local dir_or_file=$1
  local path=$2

  case $dir_or_file in
    dir)
      if [[ -d "$path" ]]; then
        echo "Directory ${path} exists. Removing it..."
        sudo rm -rf "$path"
      fi
      ;;
    file)
      if [[ -f "$path" ]]; then
        echo "File ${path} exists. Removing it..."
        sudo rm -f "$path"
      fi
      ;;
    *)
      echo "Invalid option: ${dir_or_file}. Use 'dir' or 'file'."
      ;;
  esac
}


install_packages() {
    packages=("tmux" "alacritty" "git" "neovim" "wget" "zsh" "btop" "file" "curl" "neofetch")

    if command -v apt &> /dev/null; then
        echo "Detected apt package manager. Installing packages..."
        sudo apt update
        sudo apt install -y "${packages[@]}"
        sudo apt-get install -y build-essential procps
    elif command -v yum &> /dev/null; then
        echo "Detected yum package manager. Installing packages..."
        sudo yum install -y "${packages[@]}"
        sudo yum groupinstall -y 'Development Tools'
        sudo yum install -y procps-ng
    elif command -v dnf &> /dev/null; then
        echo "Detected dnf package manager. Installing packages..."
        sudo dnf install -y "${packages[@]}"
    elif command -v pacman &> /dev/null; then
        echo "Detected pacman package manager. Installing packages..."
        sudo pacman -Syu --noconfirm "${packages[@]}"
        sudo pacman -Syu --noconfirm base-devel procps-ng
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
  rm_if_exists "dir" "/home/$user/.config/alacritty"

  sleep 1

  mkdir -p "/home/$user/.config/alacritty/"
  mkdir -p "/home/$user/.config/alacritty/themes"
  git clone "https://github.com/alacritty/alacritty-theme" "/home/$user/.config/alacritty/themes"
  sudo rm -rf "/home/$user/.config/alacritty/themes/images"

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
decorations = "Buttonless"
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

  chown -R "$user:$user" "/home/$user/.config/alacritty"

  echo "Configuration saved to '$alacritty_outpu_file'"
}

setup_tmux() {

  rm_if_exists "dir" "/home/$user/.tmux/"

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

  chown -R "$user:$user" "/home/$user/.tmux/"
  chown -R "$user:$user" "/home/$user/.tmux.config"

  echo "Configuration saved to '$tmux_output_file'"

}

setup_neovim() {
  rm_if_exists "dir" "/home/$user/.config/nvim"
  git clone "https://github.com/Leen-Configs/NeoVim-Config.git" "/home/$user/.config/nvim"
  chown -R "$user:$user" "/home/$user/.config/nvim"
}

setup_neofetch() {
  echo "neofetch" >> /home/$user/.bashrc
  echo "neofetch" >> /home/$user/.zshrc
  mkdir -p "/home/$user/.config/neofetch"
  if [[ -f "/home/$user/.config/neofetch/config.conf" ]]; then
    sudo mv "/home/$user/.config/neofetch/config.conf" "/home/$user/.config/neofetch/config.conf.bak"
  fi
  rm_if_exists "/home/$user/.config/neofetch/config.conf"
  rm_if_exists "file" "/home/$user/.config/neofetch/ascii.txt"

  curl "https://raw.githubusercontent.com/Leen-Configs/Better-Terminal-for-Devs/master/pkg/neofetch/config.conf" > /home/$user/.config/neofetch/config.conf
  curl "https://raw.githubusercontent.com/Leen-Configs/Better-Terminal-for-Devs/master/pkg/neofetch/ascii.txt" > /home/$user/.config/neofetch/ascii.txt
}

setup_terminal_tools() {
  echo "Installing Oh My Zsh..."

  mkdir -p ./pkg/ohmyzsh/
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o ./pkg/ohmyzsh/install.sh
  sed -i.bak 's|exec zsh -l|#exec zsh -l|' ./pkg/ohmyzsh/install.sh
  sh ./pkg/ohmyzsh/install.sh
  rm_if_exists "dir" "./pkg/ohmyzsh"

  git clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" "/home/$user/.config/zsh-syntax-highlighting"
  echo "source /home/$user/.config/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> /home/$user/.zshrc
  chown -R "$user:$user" "/home/$user/.config/zsh-syntax-highlighting"

  echo "setup neofetch..."
  setup_neofetch

  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> /home/$user/.bashrc
  echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> /home/$user/.zshrc
  source /home/$user/.bashrc
  brew update

  read -p "do you want to install Pyenv? (yes/no): " user_input
  if [[ -z "$user_input" || "$user_input" =~ ^([yy]|[yy][ee][ss]?)$ ]]; then
    echo "Installing PyEnv..."
    brew install pyenv

    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /home/$user/.bashrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/$user/.bashrc
    echo 'eval "$(pyenv init -)"' >> /home/$user/.bashrc

    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /home/$user/.profile
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/$user/.profile
    echo 'eval "$(pyenv init -)"' >> /home/$user/.profile

    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /home/$user/.zshrc
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/$user/.zshrc
    echo 'eval "$(pyenv init -)"' >> /home/$user/.zshrc
  fi

  echo "Installing FZF..."
  brew install fzf
  echo 'eval "$(fzf --bash)"' >> /home/$user/.bashrc
  echo 'source <(fzf --zsh)' >> /home/$user/.zshrc

  echo "Installing GCC..."
  brew install gcc

}


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
setup_terminal_tools

echo "Installation completed."

