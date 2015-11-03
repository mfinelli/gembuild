# encoding: utf-8

# Gembuild: create Arch Linux PKGBUILDs for ruby gems.
# Copyright (C) 2015  Mario Finelli <mario@finel.li>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
