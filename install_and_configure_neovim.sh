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
    FileUtils.copy(src, dst)
end

end

if !(which 'nvim')
	puts "Installing python-neovim"
    stdout_str, stderr_str, status = Open3.capture3("sudo pacman -S --needed --noconfirm python-neovim")
    if status.exitstatus != 0
        puts stderr_str
        exit status.exitstatus
    end

    puts "Installing python2-neovim"
	stdout_str, stderr_str, status = Open3.capture3("sudo pacman -S --needed --noconfirm python2-neovim")
	if status.exitstatus != 0
        puts stderr_str
        exit status.exitstatus
    end

    puts "Installing xclip"
    stdout_str, stderr_str, status = Open3.capture3("sudo pacman -S --needed --noconfirm xclip")
    if status.exitstatus != 0
        puts stderr_str
        exit status.exitstatus
    end

    puts "Installing xsel"
	stdout_str, stderr_str, status = Open3.capture3("sudo pacman -S --needed --noconfirm xsel")
    if status.exitstatus != 0
        puts stderr_str
        exit status.exitstatus
    end

    puts "Installing neovim"
    stdout_str, stderr_str, status = Open3.capture3("sudo pacman -s --needed --noconfirm neovim")
    if status.exitstatus != 0
        puts stderr_str
        exit status.exitstatus
    end

    puts "Installing clang"
    stdout_str, stderr_str, status = Open3.capture3("sudo pacman -s --needed --noconfirm clang")
    if status.exitstatus != 0
        puts stderr_str
        exit status.exitstatus
    end

    puts "Installing llvm"
    stdout_str, stderr_str, status = Open3.capture3("sudo pacman -s --needed --noconfirm llvm")
    if status.exitstatus != 0
        puts stderr_str
        exit status.exitstatus
    end
    
    puts "Installing tmux"
    stdout_str, stderr_str, status = Open3.capture3("sudo pacman -s --needed --noconfirm tmux")
    if status.exitstatus != 0
        puts stderr_str
        exit status.exitstatus
    end
end

download = open('https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
path = "#{Dir.home}/.local/share/nvim/site/autoload/plug.vim"

if !File.exists?(path)
	directory = File.dirname(path)
	unless File.directory?(directory)
		puts "Creating directory #{directory}"
		FileUtils.mkdir_p(directory)
	end

	puts "Downloading vim plug"
	IO.copy_stream(download, path)
end

if !(which 'ccls')
    puts "Installing ccls"
    stdout_str, stderr_str, status = Open3.capture3("pamac build ccls-git")
end

directory = "#{Dir.home}/.config/nvim/"
if !File.directory?(directory)
    FileUtils.mkdir_p(directory)
end

force_config_update = false
if (ARGV.size > 0 && ARGV[0] == "--force-update-config")
    force_config_update = true;
end

copy_file("#{Dir.getwd}/init.vim","#{directory}/init.vim", force_config_update)
copy_file("#{Dir.getwd}/coc-settings.json", "#{directory}/coc-settings.json", force_config_update)
copy_file("#{Dir.getwd}/.tmux.conf", "#{Dir.home}/.tmux.conf", force_config_update)
copy_file("#{Dir.getwd}/.tmuxlineSnapshot", "#{Dir.home}/.tmuxlineSnapshot", force_config_update)
