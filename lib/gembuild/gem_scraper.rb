# encoding: utf-8

require 'mechanize'
require 'nokogiri'

module Gembuild
  # This class is used to query for various information from rubygems.org.
  class GemScraper
    attr_reader :agent, :deps, :gem, :gemname, :url

    # Creates a new GemScraper instance
    #
    # @param [String] gemname The gem about which to query.
    # @return [Gembuild::GemScraper] a new GemScraper instance
    def initialize(gemname)
      fail Gembuild::UndefinedGemNameError if gemname.nil?

      @gemname = gemname
      @agent = Mechanize.new

      @url = "https://rubygems.org/api/v1/versions/#{gemname}.json"
      @deps = "https://rubygems.org/api/v1/dependencies?gems=#{gemname}"
      @gem = "https://rubygems.org/gems/#{gemname}"
    end

    # Query the rubygems version api for the latest version.
    #
    # @return [String] the latest version of the gem
    def query_latest_version
      response = JSON.parse(agent.get(url).body, symbolize_names: true)
      response.first.fetch(:number)
    end

    def scrape!
      response = JSON.parse(agent.get(url).body, symbolize_names: true).first

      pkgbuild = Gembuild::Pkgbuild.new(gemname)
      pkgbuild.pkgver = response.fetch(:number)

      pkgbuild.description = response.fetch(:description)
      pkgbuild.description = response.fetch(:summary) if pkgbuild.description.empty?
      pkgbuild.description.strip!
      pkgbuild.description += '.' unless pkgbuild.description[-1, 1] == '.'

      pkgbuild.checksum = response.fetch(:sha)

      pkgbuild.license = response.fetch(:licenses)

      dependencies = Marshal.load(agent.get(deps).body).find do |e|
        e[:number] == pkgbuild.pkgver
      end[:dependencies]

      dependencies.each do |dep|
        pkgbuild.depends << "ruby-#{dep.first}"
      end

      pkgbuild.url = Nokogiri::HTML(agent.get(gem).body).css('a').find { |a| a.text.strip == 'Homepage' }[:href]

      pkgbuild
    end

  end
end
