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

module Gembuild
  # This class is mostly responsible for creating new AUR packages: checking
  # out, adding files and committing to git.
  #
  # @!attribute [r] pkgdir
  #   @return [String] where repositories are checked out
  # @!attribute [r] pkgname
  #   @return [String] the AUR package
  class Project
    attr_reader :pkgdir, :pkgname

    # Return a new project instance.
    #
    # @param gemname [String] The ruby gem for which to create a project.
    # @return [Gembuild::Project] the new project instance
    def initialize(gemname)
      @pkgname = "ruby-#{gemname}"
      @pkgdir = ensure_pkgdir
    end

    def clone(pkg)
      `git clone ssh://aur@aur4.archlinux.org/#{pkg}.git #{File.join(@path, pkg)}`
    end

    def write_gitignore
      File.write(File.join(@path, @pkgname, '.gitignore'), "*\n!.gitignore\n!PKGBUILD\n!.SRCINFO\n")
    end

    def git_configure(name, email)
      `cd #{File.join(@path, @pkgname)} && git config user.name "#{name}"`
      `cd #{File.join(@path, @pkgname)} && git config user.email #{email}`
    end

    def stage_changes

      `cd #{File.join(@path, @pkgname)} && mksrcinfo && git add .`
    end

    def commit_message(version)
      `cd #{File.join(@path, @pkgname)} && git rev-parse HEAD &> /dev/null`

      if not $?.success?
        'Initial commit'
      else
        "Bump version to #{version}"
      end
    end

    private

    # Get the gembuild configuration and ensure that the pkgdir exists
    # creating it if necessary.
    #
    # @return [String] the pkgdir
    def ensure_pkgdir
      pkgdir = Gembuild.configure[:pkgdir]

      FileUtils.mkdir_p(pkgdir) unless File.directory?(pkgdir)

      pkgdir
    end

    # def initialize(gem)
    #   @pkgname = "ruby-#{gem}"
    #   config = Gembuild.configure

    #   FileUtils.mkdir_p config[:pkgdir]
    #   @path = config[:pkgdir]

    #   clone "ruby-#{gem}" unless File.directory? File.join(@path, "ruby-#{gem}")
    #   write_gitignore unless File.file? File.join(@path, @pkgname, '.gitignore')

    #   git_configure(config[:name], config[:email])

    #   pkgbuild = Gembuild::Pkgbuild.create(gem)
    #   File.write(File.join(@path, @pkgname, 'PKGBUILD'), pkgbuild.render)

    #   stage_changes
    #   `cd #{File.join(@path, @pkgname)} && git commit -m "#{commit_message(pkgbuild.pkgver)}"`
    # end

  end
end
