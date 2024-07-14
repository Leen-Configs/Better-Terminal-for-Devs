# Better Terminal for Developers

This repository contains a bash script to automate the setup of a development environment. The script installs essential packages and configures `Alacritty` as the default terminal emulator, along with setting up configurations for `tmux`, `neovim`, and other tools.

## Features

- Installs necessary packages (`tmux`, `alacritty`, `git`, `neovim`, `wget`, `zsh`, `btop`, `file`, `curl`, `neofetch`) based on the detected package manager.
- Configures `Alacritty` as the default terminal emulator.
- Sets up `tmux` and `neovim` with predefined configurations.
- Detects the desktop environment and applies specific settings for `Gnome`, `XFCE`, `KDE`, and others.
- Optionally installs additional tools like `Oh My Zsh`, `Homebrew`, `Pyenv`, `FZF`, and `GCC`.
- Configures `neofetch` to run on terminal startup.

## Requirements

- The script must be run with root privileges.
- An active internet connection to download packages and configurations.

## Usage

### One Command Install

```bash
sudo bash -c "$(curl -sSL https://raw.githubusercontent.com/Leen-Configs/Better-Terminal-for-Devs/master/setup.sh)" @ install
```

### Manual Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/Leen-Configs/Better-Terminal-for-Devs.git
   cd Better-Terminal-for-Devs
   ```

2. Make the script executable:

   ```bash
   chmod +x setup.sh
   ```

3. Run the script with sudo:

   ```bash
   sudo ./setup.sh
   ```

## What the Script Does

- **Installs Packages**:
  The script detects the package manager (`apt`, `dnf`, `yum`, `pacman`, `zypper`, `brew`) and installs the necessary packages.

- **Sets Up Alacritty**:

  - Creates configuration directories and files for `Alacritty`.
  - Clones the `alacritty-theme` repository for themes.
  - Applies a default configuration including font settings, keyboard bindings, window settings, etc.

- **Sets Up tmux**:

  - Clones the `tmux-plugins/tpm` repository for plugin management.
  - Configures `tmux` with mouse support, keybindings, and a predefined theme.

- **Sets Up Neovim**:

  - Clones a pre-configured Neovim setup from a specified GitHub repository.

- **Sets Alacritty as the Default Terminal**:

  - Detects the desktop environment (`Gnome`, `XFCE`, `KDE`, others) and sets `Alacritty` as the default terminal emulator.

- **Sets Up Neofetch**:

  - Configures `neofetch` to run on terminal startup by adding it to `.bashrc` and `.zshrc`.
  - Downloads and applies a custom `neofetch` configuration and ASCII art.

- **Optional Tools Setup**:
  - Installs `Oh My Zsh` and additional plugins like `zsh-syntax-highlighting`.
  - Installs `Homebrew` and optionally tools like `Pyenv`, `FZF`, and `GCC` based on user input.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---
