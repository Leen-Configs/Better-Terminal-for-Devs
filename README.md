# Better Terminal for Developers

This repository contains a bash script to automate the setup of a development environment. The script installs essential packages and configures `Alacritty` as the default terminal emulator, along with setting up configurations for `tmux` and `neovim`.

## Features

- Installs necessary packages (`tmux`, `alacritty`, `git`, `neovim`, `wget`, `zsh`) based on the detected package manager.
- Configures `Alacritty` as the default terminal emulator.
- Sets up `tmux` and `neovim` with predefined configurations.
- Detects the desktop environment and applies specific settings for `Gnome`, `XFCE`, `KDE`, and others.

## Requirements

- The script must be run with root privileges.
- An active internet connection to download packages and configurations.

## Usage

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

1. **Installs Packages**:
   The script detects the package manager (`apt`, `dnf`, `yum`, `pacman`, `zypper`, `brew`) and installs the necessary packages.

2. **Sets Up Alacritty**:

   - Creates configuration directories and files for `Alacritty`.
   - Clones the `alacritty-theme` repository for themes.
   - Applies a default configuration including font settings, keyboard bindings, window settings, etc.

3. **Sets Up tmux**:

   - Clones the `tmux-plugins/tpm` repository for plugin management.
   - Configures `tmux` with mouse support, keybindings, and a predefined theme.

4. **Sets Up Neovim**:

   - Clones a pre-configured Neovim setup from a specified GitHub repository.

5. **Sets Alacritty as the Default Terminal**:
   - Detects the desktop environment (`Gnome`, `XFCE`, `KDE`, others) and sets `Alacritty` as the default terminal emulator.

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.
