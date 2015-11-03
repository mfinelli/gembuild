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

require 'mechanize'

module Gembuild
  # This class is used to query the AUR for information about a package.
  #
  # @!attribute [r] agent
  #   @return [Mechanize] the Mechanize agent
  # @!attribute [r] pkgname
  #   @return [String] the package about which to query the AUR
  # @!attribute [r] url
  #   @return [String] the AUR url for the package
  class AurScraper
    attr_reader :agent, :pkgname, :url

    # Creates a new AurScraper instance.
    #
    # @raise [Gembuild::UndefinedPkgnameError] if the pkgname is nil or empty
    #
    # @param pkgname [String] The name of the package about which to query.
    # @return [Gembuild::AurScraper] a new AurScraper instance
    def initialize(pkgname)
      fail Gembuild::UndefinedPkgnameError if pkgname.nil? || pkgname.empty?

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
    # @param response [Hash] The JSON parsed response from the AUR.
    # @return [Boolean] whether or not the package exists already on the AUR
    def package_exists?(response)
      response[:results].count.zero? ? false : true
    end

    # Parse the version from the AUR response.
    #
    # A version string is expected to either look like 0.1.2-3 or like
    # 1:2.3.4-5. So the strategy is to first split on the dash to get the
    # package release number. Then with the remaining string attempt a split
    # on the colon. If there is only one part then it means that there is no
    # epoch (or rather that the epoch is zero). If there are two parts then we
    # use the first as the epoch value. Finally, whatever is left is the
    # actual version of the gem.
    #
    # @param response [Hash] The JSON parsed response from the AUR.
    # @return [Hash] a hash of the different version parts
    def get_version_hash(response)
      version = response[:results][:Version].split('-')

      pkgrel = version.pop.to_i
      version = version.join

      version = version.split(':')
      epoch = version.count == 1 ? 0 : version.shift.to_i
      version = Gem::Version.new(version.join)

      { epoch: epoch, pkgver: version, pkgrel: pkgrel }
    end

    # Query the AUR and returned the parsed results.
    #
    # @return [nil, Hash] the version hash or nil if the package doesn't exist
    def scrape!
      response = query_aur

      return nil unless package_exists?(response)

      get_version_hash(response)
    end
  end
end
