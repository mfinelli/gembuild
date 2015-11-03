# encoding: utf-8

require 'mechanize'
require 'nokogiri'

module Gembuild
  # This class is used to query for various information from rubygems.org.
  #
  # @!attribute [r] agent
  #   @return [Mechanize] the Mechanize agent
  # @!attribute [r] deps
  #   @return [String] the rubygems URL for getting dependency information
  # @!attribute [r] gem
  #   @return [String] the rubygems URL for the frontend
  # @!attribute [r] gemname
  #   @return [String] the rubygem about which to query
  # @!attribute [r] url
  #   @return [String] the rubygems URL to get version information
  class GemScraper
    attr_reader :agent, :deps, :gem, :gemname, :url

    # Creates a new GemScraper instance
    #
    # @raise [Gembuild::UndefinedGemName] if the gemname is nil or empty
    #
    # @param gemname [String] The gem about which to query.
    # @return [Gembuild::GemScraper] a new GemScraper instance
    def initialize(gemname)
      fail Gembuild::UndefinedGemNameError if gemname.nil? || gemname.empty?

      @gemname = gemname
      @agent = Mechanize.new

      @url = "https://rubygems.org/api/v1/versions/#{gemname}.json"
      @deps = "https://rubygems.org/api/v1/dependencies?gems=#{gemname}"
      @gem = "https://rubygems.org/gems/#{gemname}"
    end

    # Query the rubygems version api for the latest version.
    #
    # @raise [Gembuild::GemNotFoundError] if the page returns a 404 (not
    #   found) error.
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
    # @param response [Hash] The JSON parsed results from rubygems.org.
    # @return [Gem::Version] the current version of the gem
    def get_version_from_response(response)
      Gem::Version.new(response.fetch(:number))
    end

    # Gets a well-formed gem description from the parsed response.
    #
    # @param response [Hash] The JSON parsed results from rubygems.org.
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

    # Gets the sha256 checksum returned from the rubygems.org API.
    #
    # @param response [Hash] The JSON parsed results from rubygems.org.
    # @return [String] the sha256 sum of the gem file
    def get_checksum_from_response(response)
      response.fetch(:sha)
    end

    # Get the array of licenses under which the gem is licensed.
    #
    # @param response [Hash] The JSON parsed results from rubygems.org.
    # @return [Array] the licenses for the gem
    def get_licenses_from_response(response)
      response.fetch(:licenses)
    end

    # Get all other gem dependencies for the given version.
    #
    # @param version [String|Gem::Version] The version for which to get the
    #   dependencies.
    # @return [Array] list of other gems upon which the gem depends
    def get_dependencies_for_version(version)
      version = Gem::Version.new(version) if version.is_a?(String)

      payload = Marshal.load(agent.get(deps).body)

      dependencies = payload.find do |v|
        Gem::Version.new(v[:number]) == version
      end

      dependencies[:dependencies].map(&:first)
    end

    # Scrape the rubygems.org frontend for the gem's homepage URL.
    #
    # @return [String] the homepage URL of the gem
    def scrape_frontend_for_homepage_url
      html = agent.get(gem).body
      links = Nokogiri::HTML(html).css('a')

      homepage_link = links.find do |a|
        a.text.strip == 'Homepage'
      end

      homepage_link[:href]
    end

    # Quick method to get all important information in a single hash for
    # later processing.
    #
    # @return [Hash] hash containing all the information available from the
    #   rubygems.org APIs and website
    def scrape!
      response = query_latest_version
      version = get_version_from_response(response)

      {
        version: version,
        description: format_description_from_response(response),
        checksum: get_checksum_from_response(response),
        license: get_licenses_from_response(response),
        dependencies: get_dependencies_for_version(version),
        homepage: scrape_frontend_for_homepage_url
      }
    end
  end
end
