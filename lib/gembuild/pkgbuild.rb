# encoding: utf-8

module Gembuild
  class Pkgbuild

    attr_accessor :gemname, :pkgname, :pkgver, :pkgrel, :epoch, :arch,
                  :description, :url, :license, :depends, :makedepends,
                  :source, :options, :noextract, :checksum, :checksum_type

    def initialize(gemname)
      @gemname = gemname
      @pkgname = "ruby-#{@gemname}"
      @checksum_type = 'sha256'
      @arch = ['any']
    end

    def self.create(gemname)
      s = Gembuild::GemScraper.new(gemname)
      pkgbuild = s.scrape!

      s = Gembuild::AurScraper.new(pkgbuild)
      s.scrape!

      pkgbuild
    end

  end
end
