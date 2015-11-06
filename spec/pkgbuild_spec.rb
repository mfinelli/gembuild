# encoding: utf-8

require 'gembuild/pkgbuild'

describe Gembuild::Pkgbuild do
  describe '#initialize' do
    context 'with normal gem name' do
      let(:pkgbuild) { Gembuild::Pkgbuild.new('mechanize') }

      it 'should be a Pkgbuild' do
        expect(pkgbuild).to be_a(Gembuild::Pkgbuild)
      end

      it 'should have the correct gemname' do
        expect(pkgbuild.gemname).to eql('mechanize')
      end

      it 'should have the correct pkgname' do
        expect(pkgbuild.pkgname).to eql('ruby-mechanize')
      end

      it 'should have the correct checksum type' do
        expect(pkgbuild.checksum_type).to eql('sha256')
      end

      it 'should have an architecture array' do
        expect(pkgbuild.arch).to be_a(Array)
      end

      it 'should have any architecture' do
        expect(pkgbuild.arch).to eql(['any'])
      end

      it 'should have a make dependencies array' do
        expect(pkgbuild.makedepends).to be_a(Array)
      end

      it 'should have the rubygems make dependency' do
        expect(pkgbuild.makedepends).to eql(['rubygems'])
      end

      it 'should have a dependencies array' do
        expect(pkgbuild.depends).to be_a(Array)
      end

      it 'should have the ruby dependency' do
        expect(pkgbuild.depends).to eql(['ruby'])
      end

      it 'should have a source array' do
        expect(pkgbuild.source).to be_a(Array)
      end

      it 'should have the correct source' do
        expect(pkgbuild.source).to eql(['https://rubygems.org/downloads/$_gemname-$pkgver.gem'])
      end

      it 'should have a no extract array' do
        expect(pkgbuild.noextract).to be_a(Array)
      end

      it 'should have the correct no extract array' do
        expect(pkgbuild.noextract).to eql(['$_gemname-$pkgver.gem'])
      end

      it 'should have an options array' do
        expect(pkgbuild.options).to be_a(Array)
      end

      it 'should have the correct options' do
        expect(pkgbuild.options).to eql(['!emptydirs'])
      end

      it 'should have no checksum' do
        expect(pkgbuild.checksum).to be_nil
      end

      it 'should have no maintainer' do
        expect(pkgbuild.maintainer).to be_nil
      end

      it 'should have no contributor' do
        expect(pkgbuild.contributor).to eql([])
      end

      it 'should have no description' do
        expect(pkgbuild.description).to be_nil
      end

      it 'should have no epoch' do
        expect(pkgbuild.epoch).to be_nil
      end

      it 'should have no license' do
        expect(pkgbuild.license).to be_nil
      end

      it 'should have no pkgrel' do
        expect(pkgbuild.pkgrel).to be_nil
      end

      it 'should have no pkgver' do
        expect(pkgbuild.pkgver).to be_nil
      end

      it 'should have no url' do
        expect(pkgbuild.url).to be_nil
      end
    end

    context 'with string pkgbuild' do
      it 'should be a Pkgbuild' do
        expect(Gembuild::Pkgbuild.new('mechanize', '')).to be_a(Gembuild::Pkgbuild)
      end
    end

    context 'with non-string pkgbuild' do
      it 'should raise an exception' do
        expect { Gembuild::Pkgbuild.new('mechanize', {}) }.to raise_exception(Gembuild::InvalidPkgbuildError)
      end
    end
  end

  describe '#parse_existing_pkgbuild' do
    context 'with normal pkgbuild' do
      let(:pkgbuild_file) { File.read(File.join(File.dirname(__FILE__), 'fixtures', 'pkgbuild_choice')) }
      let(:pkgbuild) { Gembuild::Pkgbuild.new('choice', pkgbuild_file) }

      it 'should return a hash' do
        expect(pkgbuild.parse_existing_pkgbuild(pkgbuild_file)).to be_a(Hash)
      end

      it 'should have found a maintainer' do
        expect(pkgbuild.parse_existing_pkgbuild(pkgbuild_file)[:maintainer]).to eql('Mario Finelli <mario dot finelli at yahoo dot com>')
      end

      it 'should return a contributor array' do
        expect(pkgbuild.parse_existing_pkgbuild(pkgbuild_file)[:contributor]).to be_a(Array)
      end

      it 'should find one contributor' do
        expect(pkgbuild.parse_existing_pkgbuild(pkgbuild_file)[:contributor]).to eql(['Christopher Eby <kreed at kreed dot org>'])
      end

      it 'should return an dependencies array' do
        expect(pkgbuild.parse_existing_pkgbuild(pkgbuild_file)[:depends]).to be_a(Array)
      end

      it 'should not find any other dependencies' do
        expect(pkgbuild.parse_existing_pkgbuild(pkgbuild_file)[:depends]).to eql([])
      end

      it 'should set the pkgbuild maintainer' do
        expect(pkgbuild.maintainer).to eql('Mario Finelli <mario dot finelli at yahoo dot com>')
      end

      it 'should set the pkgbuild contributor' do
        expect(pkgbuild.contributor).to eql(['Christopher Eby <kreed at kreed dot org>'])
      end

      it 'should leave the dependencies alone' do
        expect(pkgbuild.depends).to eql(['ruby'])
      end
    end

    context 'with multiple contributors' do
      let(:pkgbuild_file) { File.read(File.join(File.dirname(__FILE__), 'fixtures', 'pkgbuild_maruku')) }
      let(:pkgbuild) { Gembuild::Pkgbuild.new('maruku', pkgbuild_file) }

      it 'should find two contributors' do
        expect(pkgbuild.parse_existing_pkgbuild(pkgbuild_file)[:contributor].count).to eql(2)
      end

      it 'should find the correct contributors' do
        expect(pkgbuild.parse_existing_pkgbuild(pkgbuild_file)[:contributor]).to eql(['Anatol Pomozov <anatol.pomozov at gmail dot com>', 'oliparcol <oliparcol at gmail dot com>'])
      end

      it 'should set the pkgbuild contributor' do
        expect(pkgbuild.contributor).to eql(['Anatol Pomozov <anatol.pomozov at gmail dot com>', 'oliparcol <oliparcol at gmail dot com>'])
      end
    end

    context 'with other dependencies' do
      let(:pkgbuild_file) { File.read(File.join(File.dirname(__FILE__), 'fixtures', 'pkgbuild_mini_magick')) }
      let(:pkgbuild) { Gembuild::Pkgbuild.new('maruku', pkgbuild_file) }

      it 'should return an array' do
        expect(pkgbuild.parse_existing_pkgbuild(pkgbuild_file)[:depends]).to be_a(Array)
      end

      it 'should return the correct dependencies' do
        expect(pkgbuild.parse_existing_pkgbuild(pkgbuild_file)[:depends]).to eql(['imagemagick'])
      end

      it 'should add the dependencies to the pkgbuild' do
        expect(pkgbuild.depends).to eql(['ruby', 'imagemagick'])
      end
    end

    context 'with no matches in pkgbuild' do
      let(:pkgbuild) { Gembuild::Pkgbuild.new('choice', '') }

      it 'should return no maintainer' do
        expect(pkgbuild.parse_existing_pkgbuild('')[:maintainer]).to be_nil
      end

      it 'should return an empty contributor array' do
        expect(pkgbuild.parse_existing_pkgbuild('')[:contributor]).to eql([])
      end

      it 'should return an empty dependencies array' do
        expect(pkgbuild.parse_existing_pkgbuild('')[:depends]).to eql([])
      end

      it 'should still have a nil maintainer in the pkgbuild' do
        expect(pkgbuild.maintainer).to be_nil
      end

      it 'should still have no contributor in the pkgbuild' do
        expect(pkgbuild.contributor).to eql([])
      end

      it 'should still only have ruby dependency' do
        expect(pkgbuild.depends).to eql(['ruby'])
      end
    end
  end

  describe '#format_contact_information' do
    let(:pkgbuild) { Gembuild::Pkgbuild.new('test') }

    context 'with normal information' do
      it 'should have the characters exchanged' do
        expect(pkgbuild.format_contact_information('Joe Smith <joe.smith@example.com>')).to eql('Joe Smith <joe dot smith at example dot com>')
      end
    end

    context 'with no information to change' do
      it 'should not change anything' do
        expect(pkgbuild.format_contact_information('some information')).to eql('some information')
      end
    end
  end

  describe '#fetch_maintainer' do
    context 'with no existing maintainer' do
      let(:pkgbuild) { Gembuild::Pkgbuild.new('mina') }

      it 'should have only the configured maintainer' do
        allow(Gembuild).to receive(:configure).and_return({name: 'Mario Finelli', email: 'mario.finelli@yahoo.com'})
        pkgbuild.fetch_maintainer
        expect(pkgbuild.maintainer).to eql('Mario Finelli <mario dot finelli at yahoo dot com>')
      end

      it 'should have no contributors' do
        allow(Gembuild).to receive(:configure).and_return({name: 'Mario Finelli', email: 'mario.finelli@yahoo.com'})
        pkgbuild.fetch_maintainer
        expect(pkgbuild.contributor).to eql([])
      end
    end

    context 'with the same maintainer' do
      let(:pkgbuild_file) { File.read(File.join(File.dirname(__FILE__), 'fixtures', 'pkgbuild_choice')) }
      let(:pkgbuild) { Gembuild::Pkgbuild.new('choice', pkgbuild_file) }

      it 'should have only the configured maintainer' do
        allow(Gembuild).to receive(:configure).and_return({name: 'Mario Finelli', email: 'mario.finelli@yahoo.com'})
        pkgbuild.fetch_maintainer
        expect(pkgbuild.maintainer).to eql('Mario Finelli <mario dot finelli at yahoo dot com>')
      end

      it 'should not adjust the contributors' do
        allow(Gembuild).to receive(:configure).and_return({name: 'Mario Finelli', email: 'mario.finelli@yahoo.com'})
        pkgbuild.fetch_maintainer
        expect(pkgbuild.contributor).to eql(['Christopher Eby <kreed at kreed dot org>'])
      end
    end

    context 'with different maintainer' do
      let(:pkgbuild_file) { File.read(File.join(File.dirname(__FILE__), 'fixtures', 'pkgbuild_choice')) }
      let(:pkgbuild) { Gembuild::Pkgbuild.new('choice', pkgbuild_file) }

      it 'should have only the configured maintainer' do
        allow(Gembuild).to receive(:configure).and_return({name: 'Mario Finelli', email: 'mario@new.com'})
        pkgbuild.fetch_maintainer
        expect(pkgbuild.maintainer).to eql('Mario Finelli <mario at new dot com>')
      end

      it 'should add the old maintainer to the contributor list' do
        allow(Gembuild).to receive(:configure).and_return({name: 'Mario Finelli', email: 'mario@new.com'})
        pkgbuild.fetch_maintainer
        expect(pkgbuild.contributor).to eql(['Mario Finelli <mario dot finelli at yahoo dot com>', 'Christopher Eby <kreed at kreed dot org>'])
      end
    end
  end

  describe '#template' do
    it 'should return a string' do
      expect(Gembuild::Pkgbuild.new('mina').template).to be_a(String)
    end

    it 'should return the template' do
      expect(Gembuild::Pkgbuild.new('mina').template).to eql(File.read(File.join(File.dirname(__FILE__), '..', 'lib', 'gembuild', 'pkgbuild.erb')))
    end
  end

  describe '#assign_gem_details' do
    context 'with gem netrc' do
      let(:pkgbuild) { Gembuild::Pkgbuild.new('netrc') }
      let(:gem_details) {
        VCR.use_cassette('gem_scraper_netrc') do
          Gembuild::GemScraper.new('netrc').scrape!
        end
      }

      it 'should assign the checksum' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.checksum).to eql('de1ce33da8c99ab1d97871726cba75151113f117146becbe45aa85cb3dabee3f')
      end

      it 'should assign the version' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.11.0'))
      end

      it 'should assign the description' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.description).to eql('This library can read and update netrc files, preserving formatting including comments and whitespace.')
      end

      it 'should assign the license' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.license).to eql(['MIT'])
      end

      it 'should not assign any extra dependencies' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.depends).to eql(['ruby'])
      end

      it 'should assign the homepage' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.url).to eql('https://github.com/geemus/netrc')
      end
    end

    context 'with gem twitter' do
      let(:pkgbuild) { Gembuild::Pkgbuild.new('twitter') }
      let(:gem_details) {
        VCR.use_cassette('gem_scraper_twitter') do
          Gembuild::GemScraper.new('twitter').scrape!
        end
      }

      it 'should assign the checksum' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.checksum).to eql('71856f234ab671c26c787f07032ce98acbc345c8fbb3194668f8de14a404bb41')
      end

      it 'should assign the version' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('5.15.0'))
      end

      it 'should assign the description' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.description).to eql('A Ruby interface to the Twitter API.')
      end

      it 'should assign the license' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.license).to eql(['MIT'])
      end

      it 'should assign the other dependencies' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.depends).to eql(['ruby', 'ruby-simple_oauth', 'ruby-naught', 'ruby-memoizable', 'ruby-json', 'ruby-http_parser.rb', 'ruby-http', 'ruby-faraday', 'ruby-equalizer', 'ruby-buftok', 'ruby-addressable'])
      end

      it 'should assign the homepage' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.url).to eql('http://sferik.github.com/twitter/')
      end
    end
  end

  describe '#assign_aur_details' do
    context 'with nil response' do
      let(:pkgbuild) { Gembuild::Pkgbuild.new('mina') }

      it 'should set the epoch to zero' do
        pkgbuild.assign_aur_details(nil)
        expect(pkgbuild.epoch).to eql(0)
      end

      it 'should set the pkgrel to one' do
        pkgbuild.assign_aur_details(nil)
        expect(pkgbuild.pkgrel).to eql(1)
      end

      it 'should leave the version alone' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(nil)
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.3.7'))
      end
    end

    context 'with equal versions' do
      let(:pkgbuild) { Gembuild::Pkgbuild.new('mina') }
      let(:results) { { epoch: 1, pkgver: Gem::Version.new('0.3.7'), pkgrel: 1 } }

      it 'should leave the epoch alone' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.epoch).to eql(1)
      end

      it 'should leave the version alone' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.3.7'))
      end

      it 'should increment the pkgrel' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.pkgrel).to eql(2)
      end
    end

    context 'with pkgver less than version' do
      let(:pkgbuild) { Gembuild::Pkgbuild.new('mina') }
      let(:results) { { epoch: 1, pkgver: Gem::Version.new('0.3.6'), pkgrel: 2 } }

      it 'should leave the epoch alone' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.epoch).to eql(1)
      end

      it 'should leave the version alone' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.3.7'))
      end

      it 'should set the pkgrel to one' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.pkgrel).to eql(1)
      end
    end

    context 'with pkgver greater than version' do
      let(:pkgbuild) { Gembuild::Pkgbuild.new('mina') }
      let(:results) { { epoch: 1, pkgver: Gem::Version.new('0.3.7'), pkgrel: 2 } }

      it 'should increment the epoch' do
        pkgbuild.pkgver = Gem::Version.new('0.3.6')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.epoch).to eql(2)
      end

      it 'should leave the version alone' do
        pkgbuild.pkgver = Gem::Version.new('0.3.6')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.3.6'))
      end

      it 'should set the pkgrel to one' do
        pkgbuild.pkgver = Gem::Version.new('0.3.6')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.pkgrel).to eql(1)
      end
    end
  end

  describe '.create' do
    context 'with gem mina and no existing pkgbuild' do
      let(:pkgbuild) {
        VCR.use_cassette('pkgbuild_mina') do
          allow(Gembuild).to receive(:configure).and_return({name: 'Mario Finelli', email: 'mario@example.com'})
          Gembuild::Pkgbuild.create('mina')
        end
      }

      it 'should return a pkgbuild' do
        expect(pkgbuild).to be_a(Gembuild::Pkgbuild)
      end

      it 'should have the correct maintainer' do
        expect(pkgbuild.maintainer).to eql('Mario Finelli <mario at example dot com>')
      end

      it 'should have the correct architecture' do
        expect(pkgbuild.arch).to eql(['any'])
      end

      it 'should have the correct checksum' do
        expect(pkgbuild.checksum).to eql('bd1fa2b56ed1aded882a12f6365a04496f5cf8a14c07f8c4f1f3cfc944ef34f6')
      end

      it 'should have the correct checksum type' do
        expect(pkgbuild.checksum_type).to eql('sha256')
      end

      it 'should have the correct contributor' do
        expect(pkgbuild.contributor).to eql([])
      end

      it 'should have the correct dependencies' do
        expect(pkgbuild.depends).to eql(['ruby', 'ruby-open4', 'ruby-rake'])
      end

      it 'should have the correct description' do
        expect(pkgbuild.description).to eql('Really fast deployer and server automation tool.')
      end

      it 'should have the correct epoch' do
        expect(pkgbuild.epoch).to eql(0)
      end

      it 'should have the correct gemname' do
        expect(pkgbuild.gemname).to eql('mina')
      end

      it 'should have the correct license' do
        expect(pkgbuild.license).to eql([])
      end

      it 'should have the correct makedepends' do
        expect(pkgbuild.makedepends).to eql(['rubygems'])
      end

      it 'should have the correct noextract' do
        expect(pkgbuild.noextract).to eql(['$_gemname-$pkgver.gem'])
      end

      it 'should have the correct options' do
        expect(pkgbuild.options).to eql(['!emptydirs'])
      end

      it 'should have the correct pkgname' do
        expect(pkgbuild.pkgname).to eql('ruby-mina')
      end

      it 'should have the correct pkgrel' do
        expect(pkgbuild.pkgrel).to eql(2)
      end

      it 'should have the correct pkgver' do
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.3.7'))
      end

      it 'should have the correct source' do
        expect(pkgbuild.source).to eql(['https://rubygems.org/downloads/$_gemname-$pkgver.gem'])
      end

      it 'should have the correct url' do
        expect(pkgbuild.url).to eql('http://github.com/nadarei/mina')
      end
    end

    context 'with gem choice and an existing pkgbuild' do
      let(:pkgbuild_file) { File.read(File.join(File.dirname(__FILE__), 'fixtures', 'pkgbuild_choice')) }
      let(:pkgbuild) {
        VCR.use_cassette('pkgbuild_choice') do
          allow(Gembuild).to receive(:configure).and_return({name: 'Mario Finelli', email: 'mario.finelli@yahoo.com'})
          Gembuild::Pkgbuild.create('choice', pkgbuild_file)
        end
      }

      it 'should return a pkgbuild' do
        expect(pkgbuild).to be_a(Gembuild::Pkgbuild)
      end

      it 'should have the correct maintainer' do
        expect(pkgbuild.maintainer).to eql('Mario Finelli <mario dot finelli at yahoo dot com>')
      end

      it 'should have the correct architecture' do
        expect(pkgbuild.arch).to eql(['any'])
      end

      it 'should have the correct checksum' do
        expect(pkgbuild.checksum).to eql('a19617f7dfd4921b38a85d0616446620de685a113ec6d1ecc85bdb67bf38c974')
      end

      it 'should have the correct checksum type' do
        expect(pkgbuild.checksum_type).to eql('sha256')
      end

      it 'should have the correct contributor' do
        expect(pkgbuild.contributor).to eql(['Christopher Eby <kreed at kreed dot org>'])
      end

      it 'should have the correct dependencies' do
        expect(pkgbuild.depends).to eql(['ruby'])
      end

      it 'should have the correct description' do
        expect(pkgbuild.description).to eql('Choice is a simple little gem for easily defining and parsing command line options with a friendly DSL.')
      end

      it 'should have the correct epoch' do
        expect(pkgbuild.epoch).to eql(0)
      end

      it 'should have the correct gemname' do
        expect(pkgbuild.gemname).to eql('choice')
      end

      it 'should have the correct license' do
        expect(pkgbuild.license).to eql(['MIT'])
      end

      it 'should have the correct makedepends' do
        expect(pkgbuild.makedepends).to eql(['rubygems'])
      end

      it 'should have the correct noextract' do
        expect(pkgbuild.noextract).to eql(['$_gemname-$pkgver.gem'])
      end

      it 'should have the correct options' do
        expect(pkgbuild.options).to eql(['!emptydirs'])
      end

      it 'should have the correct pkgname' do
        expect(pkgbuild.pkgname).to eql('ruby-choice')
      end

      it 'should have the correct pkgrel' do
        expect(pkgbuild.pkgrel).to eql(3)
      end

      it 'should have the correct pkgver' do
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.2.0'))
      end

      it 'should have the correct source' do
        expect(pkgbuild.source).to eql(['https://rubygems.org/downloads/$_gemname-$pkgver.gem'])
      end

      it 'should have the correct url' do
        expect(pkgbuild.url).to eql('http://www.github.com/defunkt/choice')
      end
    end
  end
end
