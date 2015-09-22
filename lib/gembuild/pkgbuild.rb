# encoding: utf-8

require 'erb'

module Gembuild
  class Pkgbuild

    attr_accessor :gemname, :pkgname, :pkgver, :pkgrel, :epoch, :arch,
                  :description, :url, :license, :depends, :makedepends,
                  :source, :options, :noextract, :checksum, :checksum_type,
                  :maintainer

    def initialize(gemname)
      @gemname = gemname
      @pkgname = "ruby-#{@gemname}"
      @checksum_type = 'sha256'
      @arch = ['any']
      @makedepends = ['rubygems']
      @depends = ['ruby']
      @source = ['https://rubygems.org/downloads/$_gemname-$pkgver.gem']
      @noextract = ['$_gemname-$pkgver.gem']
      @options = ['!emptydirs']
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

  end
end
