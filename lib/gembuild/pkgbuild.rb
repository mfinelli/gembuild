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

require 'erb'

module Gembuild
  # Class used to create a PKGBUILD file for a rubygem.
  #
  # @!attribute [rw] arch
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#arch
  #   @return [Array] the supported architectures
  # @!attribute [rw] checksum
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#sha256sums
  #   @return [String] the sha256 sum of the gemfile
  # @!attribute [rw] checksum_type
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#sha256sums
  #   @return [String] the type of checksum (will always be sha256)
  # @!attribute [rw] contributor
  #   @return [Array] an array of the contributors to the pkgbuild
  # @!attribute [rw] depends
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#depends
  #   @return [Array] an array of the package's dependencies (always ruby
  #     plus any other gems listed as dependencies)
  # @!attribute [rw] description
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#pkgdesc
  #   @return [String] the package description
  # @!attribute [rw] epoch
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#epoch
  #   @return [Fixnum] the package's epoch value
  # @!attribute [rw] gemname
  #   @return [String] the ruby gem for which to generate a PKGBUILD
  # @!attribute [rw] license
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#license
  #   @return [Array] an array of licenses for the gem
  # @!attribute [rw] maintainer
  #   @return [String] the package's maintainer
  # @!attribute [rw] makedepends
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#makedepends
  #   @return [Array] a list of the dependencies needed to build the package
  #     (normally just the package rubygems)
  # @!attribute [rw] noextract
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#noextract
  #   @return [Array] a list of sources not to extract with bsdtar (namely,
  #     the gemfile)
  # @!attribute [rw] options
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#options
  #   @return [Array] a list of options to pass to makepkg
  # @!attribute [rw] pkgname
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#pkgname
  #   @return [String] the name of the package (usually ruby-gem)
  # @!attribute [rw] pkgrel
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#pkgrel
  #   @return [Fixnum] the release number of the package
  # @!attribute [rw] pkgver
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#pkgver
  #   @return [Gem::Version] the version of the gem
  # @!attribute [rw] source
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#source
  #   @return [Array] a list of sources
  # @!attribute [rw] url
  #   @see https://wiki.archlinux.org/index.php/PKGBUILD#url
  #   @return [String] the URL of the homepage of the gem
  class Pkgbuild
    attr_accessor :arch, :checksum, :checksum_type, :contributor, :depends,
                  :description, :epoch, :gemname, :license, :maintainer,
                  :makedepends, :noextract, :options, :pkgname, :pkgrel,
                  :pkgver, :source, :url

    # Create a new Pkgbuild instance.
    #
    # @raise [Gembuild::InvalidPkgbuildError] if something other than a
    #   string or nil is passed as the existing pkgbuild
    #
    # @param gemname [String] The rubygem for which to create a PKGBUILD.
    # @param existing_pkgbuild [nil, String] An old PKGBUILD that can be
    #   parsed for maintainer anc contributor information.
    # @return [Gembuild::Pkgbuild] a new Pkgbuild instance
    def initialize(gemname, existing_pkgbuild = nil)
      unless existing_pkgbuild.nil? || existing_pkgbuild.is_a?(String)
        fail Gembuild::InvalidPkgbuildError
      end

      @gemname = gemname
      @pkgname = "ruby-#{@gemname}"

      set_package_defaults

      parse_existing_pkgbuild(existing_pkgbuild) unless existing_pkgbuild.nil?
    end

    # Parse the old pkgbuild (if it exists) to get information about old
    # maintainers or contributors or about other dependencies that have been
    # added but that can not be scraped from rubygems.org.
    #
    # @param pkgbuild [String] The old PKGBUILD to parse.
    # @return [Hash] a hash containing the values scraped from the PKGBUILD
    def parse_existing_pkgbuild(pkgbuild)
      pkgbuild.match(/^# Maintainer: (.*)$/) { |m| @maintainer = m[1] }

      @contributor = pkgbuild.scan(/^# Contributor: (.*)$/).flatten

      deps = parse_existing_dependencies(pkgbuild)
      deps.each do |dep|
        @depends << dep
      end

      { maintainer: maintainer, contributor: contributor, depends: deps }
    end

    def self.create(gemname)
      pkgbuild = Pkgbuild.new(gemname)

      pkgbuild.fetch_maintainer

      s = Gembuild::GemScraper.new(gemname)
      pkgbuild = s.scrape!

      s = Gembuild::AurScraper.new(pkgbuild)
      s.scrape!

      pkgbuild
    end

    def render
      ERB.new(template, 0, '-').result(binding)
    end

    def template
      File.read(File.join(File.dirname(__FILE__), 'pkgbuild.erb'))
    end

    def write
      File.write('PKGBUILD', render)
    end

    # Obfuscate the maintainer/contributors' email addresses to (help to)
    # prevent spam.
    #
    # @param contact_information [String] The maintainer or contributor
    #   byline.
    # @return [String] the information with the @s and .s exchanged
    def format_contact_information(contact_information)
      contact_information.gsub('@', ' at ').gsub('.', ' dot ')
    end

    # Set the correct maintainer for the PKGBUILD.
    #
    # If the current maintainer is nil (no old pkgbuild was passed), then do
    # nothing. If there is a maintainer then compare it to the configured
    # maintainer and if they are different then make the old maintainer a
    # contributor before setting the correct maintainer. If the maintainer is
    # nil then just set the confgured maintainer.
    #
    # @todo Write rpsec tests (after testing configuration)
    #
    # @return [String] the pkgbuild maintainer
    def fetch_maintainer
      configured_maintainer = Gembuild.configure
      m = "#{configured_maintainer[:name]} <#{configured_maintainer[:email]}>"
      new_maintainer = format_contact_information(m)

      unless maintainer.nil? || new_maintainer == maintainer
        @contributor.unshift(maintainer)
      end

      @maintainer = new_maintainer
    end

    private

    # Set the static variables of a new pkgbuild.
    #
    # @return [nil]
    def set_package_defaults
      @checksum_type = 'sha256'
      @arch = ['any']
      @makedepends = ['rubygems']
      @depends = ['ruby']
      @source = ['https://rubygems.org/downloads/$_gemname-$pkgver.gem']
      @noextract = ['$_gemname-$pkgver.gem']
      @options = ['!emptydirs']
      @contributor = []

      nil
    end

    # Scrape dependencies from an existing pkgbuild.
    #
    # @param pkgbuild [String] The PKGBUILD to search.
    # @return [Array] all existing dependencies that are not ruby or gems
    def parse_existing_dependencies(pkgbuild)
      match = pkgbuild.match(/^depends=\((.*?)\)$/m)[1]

      # First step is to remove the leading and trailing quotes. Then convert
      # all whitespace (newlines, tabs, multiple spaces, etc.) to single
      # spaces. Then, make sure that strings are quoted with ' not ".
      # Finally, split the packages into an array.
      deps = match[1..-2].gsub(/[[:space:]]+/, ' ').tr('"', "'").split("' '")

      deps.reject { |e| e.match(/^ruby/) }
    rescue
      []
    end
  end
end
