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

module Gembuild
  # This class is mostly responsible for creating new AUR packages: checking
  # out, adding files and committing to git.
  #
  # @!attribute [r] config
  #   @return [Hash] the response from Gembuild.configure
  # @!attribute [r] full_path
  #   @return [String] the full local path to the project
  # @!attribute [r] gemname
  #   @return [String] the name of the gem
  # @!attribute [r] pkgdir
  #   @return [String] where repositories are checked out
  # @!attribute [r] pkgname
  #   @return [String] the AUR package
  class Project
    attr_reader :config, :full_path, :gemname, :pkgdir, :pkgname

    # A standard gitignore for new projects that only allows the following
    # whitelisted files: itself, the PKGBUILD and the .SRCINFO.
    GITIGNORE = "*\n!.gitignore\n!PKGBUILD\n!.SRCINFO\n"

    # Return a new project instance.
    #
    # @param gemname [String] The ruby gem for which to create a project.
    # @return [Gembuild::Project] the new project instance
    def initialize(gemname)
      @pkgname = "ruby-#{gemname}"
      @gemname = gemname

      @config = Gembuild.configure
      @pkgdir = @config[:pkgdir]
      @full_path = File.join(@pkgdir, @pkgname)
    end

    # Git clone the project if it hasn't already been checked out. If it has
    # then pull master to ensure the most recent update.
    #
    # @return [void]
    def clone_and_update!
      if File.directory?(full_path)
        `cd #{full_path} && git checkout master && git pull origin master`
      else
        `git clone ssh://aur@aur4.archlinux.org/#{pkgname}.git #{full_path}`
      end
    end

    # Write a standard gitignore file if none exists.
    #
    # @return [void]
    def write_gitignore!
      ignore_path = File.join(full_path, '.gitignore')

      File.write(ignore_path, GITIGNORE) unless File.exist?(ignore_path)
    end

    # Ensure that the git user and email address are correct for the
    # repository.
    #
    # @param name [String] The user name to send to git.
    # @param email [String] The user email to send to git.
    # @return [void]
    def configure_git!(name, email)
      `cd #{full_path} && git config user.name "#{name}"`
      `cd #{full_path} && git config user.email "#{email}"`
    end

    # Read into memory the PKGBUILD in the project's directory or an empty
    # string if none exists.
    #
    # @return [String] the existing pkgbuild or an empty string
    def load_existing_pkgbuild
      pkgbuild_path = File.join(full_path, 'PKGBUILD')

      if File.file?(pkgbuild_path)
        File.read(pkgbuild_path)
      else
        ''
      end
    end

    # Update the package metadata with mksrcinfo and then stage all changes
    # with git.
    #
    # @return [void]
    def stage_changes!
      `cd #{full_path} && mksrcinfo && git add .`
    end

    # Determine the commit message depending upon whether it's the initial
    # commit or we're bumping the release.
    #
    # @param version [String] The version of the package to include in the
    #   commit message.
    # @return [String] the appropriate commit message
    def commit_message(version)
      `cd #{full_path} && git rev-parse HEAD &> /dev/null`

      if !$CHILD_STATUS.success?
        'Initial commit'
      else
        "Bump version to #{version}"
      end
    end

    # Commit the currently staged changeset.
    #
    # @param message [String] The requested commit message.
    # @return [void]
    def commit_changes(message)
      `cd #{full_path} && git commit -m "#{message}"`
    end

    # Get the gembuild configuration and ensure that the pkgdir exists
    # creating it if necessary.
    #
    # @return [void]
    def ensure_pkgdir!
      FileUtils.mkdir_p(pkgdir) unless File.directory?(pkgdir)
    end

    def all_together
      ensure_pkgdir!
      clone_and_update!
      write_gitignore!
      configure_git!(config[:name], config[:email])

      pkgbuild = Gembuild::Pkgbuild.create(gemname, load_existing_pkgbuild)
      pkgbuild.write(full_path)

      stage_changes!
      commit_changes(commit_message(pkgbuild.pkgver))
    end
  end
end
