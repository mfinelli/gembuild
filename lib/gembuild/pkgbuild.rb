# encoding: utf-8

require 'erb'

module Gembuild
  # Class used to create a PKGBUILD file for a rubygem.
  class Pkgbuild
    attr_accessor :arch, :checksum, :checksum_type, :contributor, :depends,
                  :description, :epoch, :gemname, :license, :maintainer,
                  :makedepends, :noextract, :options, :pkgname, :pkgrel,
                  :pkgver, :source, :url

    # Create a new Pkgbuild instance.
    #
    # @param [String] gemname The rubygem for which to create a PKGBUILD.
    # @param [String] existing_pkgbuild An old PKGBUILD that can be parsed for
    #   maintainer anc contributor information.
    # @return [Gembuild::Pkgbuild] a new Pkgbuild instance
    def initialize(gemname, existing_pkgbuild = nil)
      unless existing_pkgbuild.nil? || existing_pkgbuild.is_a?(String)
        fail Gembuild::InvalidPkgbuildError
      end

      @gemname = gemname
      @pkgname = "ruby-#{@gemname}"

      parse_existing_pkgbuild(existing_pkgbuild) unless existing_pkgbuild.nil?

      set_package_defaults
    end

    # Parse the old pkgbuild (if it exists) to get information about old
    # maintainers or contributors or about other dependencies that have been
    # added but that can not be scraped from rubygems.org.
    #
    # param [String] pkgbuild The old PKGBUILD to parse.
    # return [Hash] a hash containing the values scraped from the PKGBUILD
    def parse_existing_pkgbuild(pkgbuild)
      maintainer = pkgbuild.match(/^# Maintainer: (.*)$/)[1] rescue nil
      contributor = pkgbuild.scan(/^# Contributor: (.*)$/).flatten

      {
        maintainer: maintainer,
        contributor: contributor,
        depends: []
      }
    end

    def self.create(gemname)
      maintainer = Gembuild.configure

      s = Gembuild::GemScraper.new(gemname)
      pkgbuild = s.scrape!

      pkgbuild.maintainer = "#{maintainer[:name]} <#{maintainer[:email].gsub('@', ' at ').gsub('.', ' dot ')}>"

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

      nil
    end
  end
end
