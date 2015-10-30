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
    # @return [Hash] the information about the latest version of the gem
    def query_latest_version
      response = JSON.parse(agent.get(url).body, symbolize_names: true)

      # Skip any release marked as a "prerelease"
      response.shift while response.first[:prerelease]

      response.first
    rescue Mechanize::ResponseCodeError, Net::HTTPNotFound
      raise Gembuild::GemNotFoundError
    end

    # Gets the version number from the parsed response.
    #
    # @param [Hash] response The JSON parsed results from rubygems.org.
    # @return [Gem::Version] the current version of the gem
    def get_version_from_response(response)
      Gem::Version.new(response.fetch(:number))
    end

    # Gets a well-formed gem description from the parsed response.
    #
    # @param [Hash] response The JSON parsed results from rubygems.org.
    # @return [String] the gem description or summary ending in a full-stop
    def format_description_from_response(response)
      description = response.fetch(:description)
      description = response.fetch(:summary) if description.empty?

      # Replace any newlines or tabs (which would mess up a PKGBUILD) with
      # spaces. Then, make sure there is no
      description = description.gsub(/[[:space:]]+/, ' ').strip

      # Ensure that the description ends in a full-stop.
      description += '.' unless description[-1, 1] == '.'

      description
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
