# encoding: utf-8

require 'mechanize'

module Gembuild
  # This class is used to query the AUR for information about a package.
  class AurScraper
    attr_reader :agent, :pkgname, :url

    # Creates a new AurScraper instance.
    #
    # @param [String] pkgname The name of the package about which to query.
    # @return [Gembuild::AurScraper] a new AurScraper instance
    def initialize(pkgname)
      fail Gembuild::UndefinedPkgnameError if pkgname.nil?

      @agent = Mechanize.new
      @pkgname = pkgname

      @url = "https://aur.archlinux.org/rpc.php?type=info&arg=#{pkgname}"
    end

    # Query the AUR for information about a package and then parse the JSON
    # results.
    #
    # @return [Hash] the information about the package
    def query_aur
      JSON.parse(agent.get(url).body, symbolize_names: true)
    end

    # Determine whether the package already exists on the AUR by the number of
    # results returned.
    #
    # @param [Hash] The JSON parsed response from the AUR.
    # @return [Boolean] whether or not the package exists already on the AUR
    def package_exists?(response)
      response[:results].count.zero? ? false : true
    end

    def get_version_hash(response)
      version = response[:results][:Version].split('-')

      pkgrel = version.pop.to_i
      version = version.join

      version = version.split(':')
      epoch = version.count == 1 ? 0 : version.shift
      version = version.join

      { epoch: epoch, pkgver: version, pkgrel: pkgrel }
    end

    def scrape!
      response = JSON.parse(agent.get(url).body, symbolize_names: true)

      if response[:results].count.zero?
        pkgbuild.epoch = 0
        pkgbuild.pkgrel = 1
      else
        response = response[:results]

        version = response[:Version].split('-')

        pkgrel = version.pop
        version = version.join

        version = version.split(':')
        if version.count == 1
          epoch = 0
        else
          epoch = version.shift
        end
        version = version.join

        pkgbuild.epoch = epoch
        pkgbuild.pkgrel = pkgrel

        aur_version = Gem::Version.new(version)
        gem_version = Gem::Version.new(pkgbuild.pkgver)

        if gem_version == aur_version
          pkgbuild.pkgrel += 1
        else
          pkgbuild.pkgrel = 1
        end
      end
    end
  end
end
