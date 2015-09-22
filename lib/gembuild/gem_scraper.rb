# encoding: utf-8

require 'mechanize'

module Gembuild
  class GemScraper

    attr_reader :agent, :gemname, :url

    def initialize(gemname)
      @gemname = gemname
      @agent = Mechanize.new

      @url = "https://rubygems.org/api/v1/versions/#{gemname}.json"
    end

    def scrape!
      response = JSON.parse(agent.get(url).body, symbolize_names: true).first

      pkgbuild = Gembuild::Pkgbuild.new(gemname)
      pkgbuild.pkgver = response.fetch(:number)

      pkgbuild.description = response.fetch(:description)
      pkgbuild.description = response.fetch(:summary) if pkgbuild.description.empty?
      pkgbuild.description += '.' unless pkgbuild.description[-1, 1] == '.'

      pkgbuild.checksum = response.fetch(:sha)

      pkgbuild.license = response.fetch(:licenses)

      pkgbuild
    end

  end
end
