#!/usr/bin/env ruby

require 'open3'
require 'open-uri'
require 'fileutils'

def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return nil
end

def copy_file(src, dst, force_copy)
if (!File.file?(dst) || force_copy)
    if File.file?(dst)
        FileUtils.remove(dst)
    end
    FileUtils.copy(src, dst)
end

end

def download_file(url, destination, override = false)
    if (!File.exists?(destination) || override)
        download = open(url)
	    directory = File.dirname(destination)
        unless File.directory?(directory)
		    puts "Creating directory #{directory}"
		    FileUtils.mkdir_p(directory)
	    end
        puts "Downloading #{destination}"
        IO.copy_stream(download, destination)
    end
end

def execute_command(command)
    stdout_str, stderr_str, status = Open3.capture3(command)
    if status.exitstatus != 0
        STDERR.puts stderr_str
        exit status.exitstatus
    end
end

def pacman_install(target)
    STDERR.puts "Installing #{target}"
    execute_command("sudo pacman -S --needed --noconfirm #{target}")
end

if !(which 'nvim')
    pacman_install 'python-neovim'
    pacman_install 'python2-neovim'
    pacman_install 'xclip'
    pacman_install 'xsel'
    pacman_install 'neovim'
    pacman_install 'clang'
    pacman_install 'llvm'
    pacman_install 'tmux'
else
    STDERR.puts "Neovim was already installed"
end

download = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
path = "#{Dir.home}/.local/share/nvim/site/autoload/plug.vim"

download_file(download, path)

#TODO need to refactor installing ccls manually. Git clone, then build by cmake... Pamac not working inside script...
if !(which 'ccls')
    puts "Installing ccls"
    stdout_str, stderr_str, status = Open3.capture3("pamac build ccls-git")
end

directory = "#{Dir.home}/.config/nvim/"
if !File.directory?(directory)
    FileUtils.mkdir_p(directory)
end

force_update_config = false
if (ARGV.size > 0 && ARGV[0] == "--force-update-config")
    puts "Force updating config files"
    force_config_update = true
end

copy_file("#{Dir.getwd}/init.vim","#{directory}/init.vim", force_update_config)
copy_file("#{Dir.getwd}/coc-settings.json", "#{directory}/coc-settings.json", force_update_config)
copy_file("#{Dir.getwd}/.tmux.conf", "#{Dir.home}/.tmux.conf", force_update_config)

stdout_str, stderr_str, status = Open3.capture3("nvim +'PlugInstall --sync' +qa")

font_url = "https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete%20Mono.ttf?raw=true"

#download patched font and set it as terminal font
download_file(font_url, "#{Dir.home}/.local/share/fonts/Hack Regular Nerd Font Complete.ttf")
execute_command "fc-cache -fv"
execute_command "gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font Mono 11'"
