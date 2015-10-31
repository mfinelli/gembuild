# encoding: utf-8

require 'erb'

module Gembuild
  # Class used to create a PKGBUILD file for a rubygem.
  class Pkgbuild

    attr_accessor :gemname, :pkgname, :pkgver, :pkgrel, :epoch, :arch,
                  :description, :url, :license, :depends, :makedepends,
                  :source, :options, :noextract, :checksum, :checksum_type,
                  :maintainer

    # Create a new Pkgbuild instance.
    #
    # @param [String] gemname The rubygem for which to create a PKGBUILD.
    # @param [String] existing_pkgbuild An old PKGBUILD that can be parsed for
    #   maintainer anc contributor information.
    # @return [Gembuild::Pkgbuild] a new Pkgbuild instance
    def initialize(gemname, existing_pkgbuild = nil)
      unless existing_pkgbuild.nil? or existing_pkgbuild.is_a?(String)
        fail Gembuild::InvalidPkgbuildError
      end

      @gemname = gemname
      @pkgname = "ruby-#{@gemname}"

      set_package_defaults
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
