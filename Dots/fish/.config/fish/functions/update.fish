function update
    argparse shutdown -- $argv
    
    sudo pacman -Syu --noconfirm
    yay -Syu --noconfirm
    flatpak update -y
    
    if set -q _flag_shutdown
        shutdown now
    end
end
