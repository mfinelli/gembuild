require 'gembuild/aur_scraper'
require 'gembuild/exceptions'
require 'gembuild/gem_scraper'
require 'gembuild/pkgbuild'
require 'gembuild/project'
require 'gembuild/version'

module Gembuild
  class << self

    def configure
      conf_file = File.expand_path(File.join('~', '.gembuild'))

      unless File.file?(conf_file)
        name = get_git_name
        email = get_git_email
        pkgdir = get_pkgdir

        File.write(
            conf_file,
            {
                name: name,
                email: email,
                pkgdir: pkgdir
            }.to_yaml)
      end

      YAML.load_file(conf_file)
    end

    def get_git_name
      name = `git config --global user.name`.strip

      if $?.success?
        puts "Detected \"#{name}\", is this correct? (y/n)"
        response = gets.chomp.downcase[0, 1]

        if response == 'y'
          return name
        else
          puts 'Please enter desired name: '
          return gets.chomp
        end
      else
        puts 'Could not detect name from git configuration.'
        puts 'Please enter desired name: '
        gets.chomp
      end
    end

    def get_git_email
      email = `git config --global user.email`.strip

      if $?.success?
        puts "Detected \"#{email}\", is this correct? (y/n)"
        response = gets.chomp.downcase[0, 1]

        if response == 'y'
          return email
        else
          puts 'Please enter desired email: '
          return gets.chomp
        end
      else
        puts 'Could not detect email from git configuration.'
        puts 'Please enter desired email: '
        gets.chomp
      end
    end

    def get_pkgdir
      puts 'Where should projects be checked out?'
      File.expand_path(gets.chomp)
    end

  end
end
