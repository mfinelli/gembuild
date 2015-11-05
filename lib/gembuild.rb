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

require 'English'

require 'gembuild/aur_scraper'
require 'gembuild/exceptions'
require 'gembuild/gem_scraper'
require 'gembuild/pkgbuild'
require 'gembuild/project'
require 'gembuild/version'

# Create Arch Linux PKGBUILDs for ruby gems.
module Gembuild
  class << self
    # The path to the gembuild configuration file.
    #
    # @return [String] real path to the configuration file
    def conf_file
      File.expand_path(File.join('~', '.gembuild'))
    end

    # Read from the configuration file if it exists, otherwise prompt for the
    # configuration and save it to file.
    #
    # @return [Hash] the configuration options: maintainer name and email
    #   address and where to checkout packages
    def configure
      unless File.file?(conf_file)
        name = fetch_git_global_name
        email = fetch_git_global_email
        pkgdir = get_pkgdir

        File.write(
          conf_file,
          { name: name, email: email, pkgdir: pkgdir }.to_yaml
        )
      end

      YAML.load_file(conf_file)
    end

    # Attempt to read the global git name, prompting the user for the name if
    # unsuccessful.
    #
    # @return [String] the name to use as package maintainer
    def fetch_git_global_name
      name = `git config --global user.name`.strip

      if $CHILD_STATUS.success?
        if prompt_for_confirmation(name)
          return name
        else
          prompt_for_git_name
        end
      else
        prompt_for_git_name('Could not detect name from git configuration.')
      end
    end

    # Attempt to read the global git email, prompting the user for the email
    # if unsuccessful.
    #
    # @return [String] the email to use as package maintainer
    def fetch_git_global_email
      email = `git config --global user.email`.strip

      if $CHILD_STATUS.success?
        if prompt_for_confirmation(email)
          return email
        else
          prompt_for_git_email
        end
      else
        prompt_for_git_email('Could not detect email from git configuration.')
      end
    end

    # Prompt the user for the name to use.
    #
    # This method is only called if reading the global git configuration was
    # unsuccessful or the user specified that it was incorrect.
    #
    # @param msg [String, nil] An optional message to display before
    #   prompting.
    # @return [String] the name to use as package maintainer
    def prompt_for_git_name(msg = nil)
      puts msg unless msg.nil? || msg.empty?
      puts 'Please enter desired name: '
      gets.chomp
    end

    # Prompt the user for the email to use.
    #
    # This method is only called if reading the global git configuration was
    # unsuccessful or the user specified that it was incorrect.
    #
    # @param msg [String, nil] An optional message to display before
    #   prompting.
    # @return [String] the email address to use as package maintainer
    def prompt_for_git_email(msg = nil)
      puts msg unless msg.nil? || msg.empty?
      puts 'Please enter desired email: '
      gets.chomp
    end

    # Ask the user to confirm the detected value.
    #
    # @param detected [String] The value that was detected.
    # @return [Boolean] whether or not the value is correct
    def prompt_for_confirmation(detected)
      puts "Detected \"#{detected}\", is this correct? (y/n)"
      response = gets.chomp.downcase[0, 1]

      (response == 'y') ? true : false
    end

    def get_pkgdir
      puts 'Where should projects be checked out?'
      File.expand_path(gets.chomp)
    end
  end
end
