# encoding: utf-8

require 'mechanize'

module Gembuild
  class AurScraper

    attr_reader :agent, :pkgbuild, :pkgname, :url

    def initialize(pkgbuild)
      @agent = Mechanize.new
      @pkgbuild = pkgbuild
      @pkgname = pkgbuild.pkgname

      @url = "https://aur.archlinux.org/rpc.php?type=info&arg=#{pkgname}"
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

        Gem::Version.new(version)
      end
    end

  end
end
