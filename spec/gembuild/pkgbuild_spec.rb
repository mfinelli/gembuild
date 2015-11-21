# encoding: utf-8

require 'gembuild/pkgbuild'

describe Gembuild::Pkgbuild do
  let(:path_to_fixtures) do
    File.join(File.dirname(__FILE__), '..', 'fixtures')
  end

  describe '#initialize' do
    context 'with normal gem name' do
      let(:pkgbuild) { described_class.new('mechanize') }

      it 'is a Pkgbuild' do
        expect(pkgbuild).to be_a(described_class)
      end

      it 'has the correct gemname' do
        expect(pkgbuild.gemname).to eql('mechanize')
      end

      it 'has the correct pkgname' do
        expect(pkgbuild.pkgname).to eql('ruby-mechanize')
      end

      it 'has the correct checksum type' do
        expect(pkgbuild.checksum_type).to eql('sha256')
      end

      it 'has an architecture array' do
        expect(pkgbuild.arch).to be_a(Array)
      end

      it 'has any architecture' do
        expect(pkgbuild.arch).to eql(['any'])
      end

      it 'has a make dependencies array' do
        expect(pkgbuild.makedepends).to be_a(Array)
      end

      it 'has the rubygems make dependency' do
        expect(pkgbuild.makedepends).to eql(['rubygems'])
      end

      it 'has a dependencies array' do
        expect(pkgbuild.depends).to be_a(Array)
      end

      it 'has the ruby dependency' do
        expect(pkgbuild.depends).to eql(['ruby'])
      end

      it 'has a source array' do
        expect(pkgbuild.source).to be_a(Array)
      end

      it 'has the correct source' do
        url = 'https://rubygems.org/downloads/$_gemname-$pkgver.gem'
        expect(pkgbuild.source).to eql([url])
      end

      it 'has a no extract array' do
        expect(pkgbuild.noextract).to be_a(Array)
      end

      it 'has the correct no extract array' do
        expect(pkgbuild.noextract).to eql(['$_gemname-$pkgver.gem'])
      end

      it 'has an options array' do
        expect(pkgbuild.options).to be_a(Array)
      end

      it 'has the correct options' do
        expect(pkgbuild.options).to eql(['!emptydirs'])
      end

      it 'has no checksum' do
        expect(pkgbuild.checksum).to be_nil
      end

      it 'has no maintainer' do
        expect(pkgbuild.maintainer).to be_nil
      end

      it 'has no contributor' do
        expect(pkgbuild.contributor).to eql([])
      end

      it 'has no description' do
        expect(pkgbuild.description).to be_nil
      end

      it 'has no epoch' do
        expect(pkgbuild.epoch).to be_nil
      end

      it 'has no license' do
        expect(pkgbuild.license).to be_nil
      end

      it 'has no pkgrel' do
        expect(pkgbuild.pkgrel).to be_nil
      end

      it 'has no pkgver' do
        expect(pkgbuild.pkgver).to be_nil
      end

      it 'has no url' do
        expect(pkgbuild.url).to be_nil
      end
    end

    context 'with string pkgbuild' do
      it 'is a Pkgbuild' do
        expect(described_class.new('mechanize', '')).to be_a(described_class)
      end
    end

    context 'with empty string pkgbuild' do
      it 'doesn\'t call parse_existing_pkgbuild' do
        method = :parse_existing_pkgbuild
        expect_any_instance_of(described_class).to_not receive(method)
        described_class.new('mina', '')
      end
    end

    context 'with nil pkgbuild' do
      it 'does not call parse_existing_pkgbuild' do
        method = :parse_existing_pkgbuild
        expect_any_instance_of(described_class).to_not receive(method)
        described_class.new('mina', nil)
      end
    end

    context 'with non-nil, non-empty pkgbuild' do
      it 'calls parse_existing_pkgbuild' do
        method = :parse_existing_pkgbuild
        expect_any_instance_of(described_class).to receive(method)
          .with('TEST')
        described_class.new('mina', 'TEST')
      end
    end

    context 'with non-string pkgbuild' do
      it 'raises an exception' do
        ex = Gembuild::InvalidPkgbuildError
        expect { described_class.new('mechanize', {}) }.to raise_exception(ex)
      end
    end
  end

  describe '#parse_existing_pkgbuild' do
    context 'with normal pkgbuild' do
      let(:pkgbuild_file) do
        File.read(File.join(path_to_fixtures, 'pkgbuild_choice'))
      end

      let(:pkgbuild) { described_class.new('choice', pkgbuild_file) }

      let(:parsed_pkgbuild) do
        pkgbuild.parse_existing_pkgbuild(pkgbuild_file)
      end

      it 'returns a hash' do
        expect(parsed_pkgbuild).to be_a(Hash)
      end

      it 'finds a maintainer' do
        maintainer = 'Mario Finelli <mario dot finelli at yahoo dot com>'
        expect(parsed_pkgbuild[:maintainer]).to eql(maintainer)
      end

      it 'returns a contributor array' do
        expect(parsed_pkgbuild[:contributor]).to be_a(Array)
      end

      it 'finds one contributor' do
        contributor = 'Christopher Eby <kreed at kreed dot org>'
        expect(parsed_pkgbuild[:contributor]).to eql([contributor])
      end

      it 'returns an dependencies array' do
        expect(parsed_pkgbuild[:depends]).to be_a(Array)
      end

      it 'does not find any other dependencies' do
        expect(parsed_pkgbuild[:depends]).to eql([])
      end

      it 'sets the pkgbuild maintainer' do
        maintainer = 'Mario Finelli <mario dot finelli at yahoo dot com>'
        expect(pkgbuild.maintainer).to eql(maintainer)
      end

      it 'sets the pkgbuild contributor' do
        contributor = 'Christopher Eby <kreed at kreed dot org>'
        expect(pkgbuild.contributor).to eql([contributor])
      end

      it 'leaves the dependencies alone' do
        expect(pkgbuild.depends).to eql(['ruby'])
      end
    end

    context 'with multiple contributors' do
      let(:pkgbuild_file) do
        File.read(File.join(path_to_fixtures, 'pkgbuild_maruku'))
      end

      let(:pkgbuild) { described_class.new('maruku', pkgbuild_file) }

      let(:parsed_pkgbuild) do
        pkgbuild.parse_existing_pkgbuild(pkgbuild_file)
      end

      it 'finds two contributors' do
        expect(parsed_pkgbuild[:contributor].count).to eql(2)
      end

      it 'finds the correct contributors' do
        contributors = ['Anatol Pomozov <anatol.pomozov at gmail dot com>',
                        'oliparcol <oliparcol at gmail dot com>']
        expect(parsed_pkgbuild[:contributor]).to eql(contributors)
      end

      it 'sets the pkgbuild contributor' do
        contributors = ['Anatol Pomozov <anatol.pomozov at gmail dot com>',
                        'oliparcol <oliparcol at gmail dot com>']
        expect(pkgbuild.contributor).to eql(contributors)
      end
    end

    context 'with other dependencies' do
      let(:pkgbuild_file) do
        File.read(File.join(path_to_fixtures, 'pkgbuild_mini_magick'))
      end

      let(:pkgbuild) { described_class.new('maruku', pkgbuild_file) }

      let(:parsed_pkgbuild) do
        pkgbuild.parse_existing_pkgbuild(pkgbuild_file)
      end

      it 'returns an array' do
        expect(parsed_pkgbuild[:depends]).to be_a(Array)
      end

      it 'returns the correct dependencies' do
        expect(parsed_pkgbuild[:depends]).to eql(['imagemagick'])
      end

      it 'adds the dependencies to the pkgbuild' do
        expect(pkgbuild.depends).to eql(%w(ruby imagemagick))
      end
    end

    context 'with no matches in pkgbuild' do
      let(:pkgbuild) { described_class.new('choice', '') }

      it 'returns no maintainer' do
        expect(pkgbuild.parse_existing_pkgbuild('')[:maintainer]).to be_nil
      end

      it 'returns an empty contributor array' do
        expect(pkgbuild.parse_existing_pkgbuild('')[:contributor]).to eql([])
      end

      it 'returns an empty dependencies array' do
        expect(pkgbuild.parse_existing_pkgbuild('')[:depends]).to eql([])
      end

      it 'still has a nil maintainer in the pkgbuild' do
        expect(pkgbuild.maintainer).to be_nil
      end

      it 'still has no contributor in the pkgbuild' do
        expect(pkgbuild.contributor).to eql([])
      end

      it 'still only has the ruby dependency' do
        expect(pkgbuild.depends).to eql(['ruby'])
      end
    end
  end

  describe '#format_contact_information' do
    let(:pkgbuild) { described_class.new('test') }

    context 'with normal information' do
      it 'has the characters exchanged' do
        input = 'Joe Smith <joe.smith@example.com>'
        output = 'Joe Smith <joe dot smith at example dot com>'
        expect(pkgbuild.format_contact_information(input)).to eql(output)
      end
    end

    context 'with no information to change' do
      it 'does not change anything' do
        input = 'some information'
        output = 'some information'
        expect(pkgbuild.format_contact_information(input)).to eql(output)
      end
    end
  end

  describe '#fetch_maintainer' do
    context 'with no existing maintainer' do
      let(:pkgbuild) { described_class.new('mina') }

      it 'has only the configured maintainer' do
        expected = 'Mario Finelli <mario dot finelli at yahoo dot com>'
        allow(Gembuild).to receive(:configure).and_return(
          name: 'Mario Finelli',
          email: 'mario.finelli@yahoo.com')
        pkgbuild.fetch_maintainer
        expect(pkgbuild.maintainer).to eql(expected)
      end

      it 'has no contributors' do
        allow(Gembuild).to receive(:configure).and_return(
          name: 'Mario Finelli',
          email: 'mario.finelli@yahoo.com')
        pkgbuild.fetch_maintainer
        expect(pkgbuild.contributor).to eql([])
      end
    end

    context 'with the same maintainer' do
      let(:pkgbuild_file) do
        File.read(File.join(path_to_fixtures, 'pkgbuild_choice'))
      end

      let(:pkgbuild) { described_class.new('choice', pkgbuild_file) }

      it 'has only the configured maintainer' do
        expected = 'Mario Finelli <mario dot finelli at yahoo dot com>'
        allow(Gembuild).to receive(:configure).and_return(
          name: 'Mario Finelli', email: 'mario.finelli@yahoo.com')
        pkgbuild.fetch_maintainer
        expect(pkgbuild.maintainer).to eql(expected)
      end

      it 'does not adjust the contributors' do
        expected = 'Christopher Eby <kreed at kreed dot org>'
        allow(Gembuild).to receive(:configure).and_return(
          name: 'Mario Finelli', email: 'mario.finelli@yahoo.com')
        pkgbuild.fetch_maintainer
        expect(pkgbuild.contributor).to eql([expected])
      end
    end

    context 'with different maintainer' do
      let(:pkgbuild_file) do
        File.read(File.join(path_to_fixtures, 'pkgbuild_choice'))
      end

      let(:pkgbuild) { described_class.new('choice', pkgbuild_file) }

      it 'has only the configured maintainer' do
        expected = 'Mario Finelli <mario at new dot com>'
        allow(Gembuild).to receive(:configure).and_return(
          name: 'Mario Finelli', email: 'mario@new.com')
        pkgbuild.fetch_maintainer
        expect(pkgbuild.maintainer).to eql(expected)
      end

      it 'adds the old maintainer to the contributor list' do
        expected = ['Mario Finelli <mario dot finelli at yahoo dot com>',
                    'Christopher Eby <kreed at kreed dot org>']
        allow(Gembuild).to receive(:configure).and_return(
          name: 'Mario Finelli', email: 'mario@new.com')
        pkgbuild.fetch_maintainer
        expect(pkgbuild.contributor).to eql(expected)
      end
    end
  end

  describe '#template' do
    it 'returns a string' do
      expect(described_class.new('mina').template).to be_a(String)
    end

    it 'returns the template' do
      expect(described_class.new('mina').template).to eql(
        File.read(File.join(File.dirname(__FILE__),
                            '..',
                            '..',
                            'lib',
                            'gembuild',
                            'pkgbuild.erb')))
    end
  end

  describe '#assign_gem_details' do
    context 'with gem netrc' do
      let(:pkgbuild) { described_class.new('netrc') }

      let(:gem_details) do
        VCR.use_cassette('gem_scraper_netrc') do
          Gembuild::GemScraper.new('netrc').scrape!
        end
      end

      it 'assigns the checksum' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.checksum).to eql('de1ce33da8c99ab1d97871726cba7515' \
                                         '1113f117146becbe45aa85cb3dabee3f')
      end

      it 'assigns the version' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.11.0'))
      end

      it 'assigns the description' do
        description = 'This library can read and update netrc files, ' \
                      'preserving formatting including comments and ' \
                      'whitespace.'

        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.description).to eql(description)
      end

      it 'assigns the license' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.license).to eql(['MIT'])
      end

      it 'does not assign any extra dependencies' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.depends).to eql(['ruby'])
      end

      it 'assigns the homepage' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.url).to eql('https://github.com/geemus/netrc')
      end
    end

    context 'with gem twitter' do
      let(:pkgbuild) { described_class.new('twitter') }

      let(:gem_details) do
        VCR.use_cassette('gem_scraper_twitter') do
          Gembuild::GemScraper.new('twitter').scrape!
        end
      end

      it 'assigns the checksum' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.checksum).to eql('71856f234ab671c26c787f07032ce98a' \
                                         'cbc345c8fbb3194668f8de14a404bb41')
      end

      it 'assigns the version' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('5.15.0'))
      end

      it 'assigns the description' do
        description = 'A Ruby interface to the Twitter API.'
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.description).to eql(description)
      end

      it 'assigns the license' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.license).to eql(['MIT'])
      end

      it 'assigns the other dependencies' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.depends).to eql(['ruby',
                                         'ruby-simple_oauth',
                                         'ruby-naught',
                                         'ruby-memoizable',
                                         'ruby-json',
                                         'ruby-http_parser.rb',
                                         'ruby-http',
                                         'ruby-faraday',
                                         'ruby-equalizer',
                                         'ruby-buftok',
                                         'ruby-addressable'])
      end

      it 'assigns the homepage' do
        pkgbuild.assign_gem_details(gem_details)
        expect(pkgbuild.url).to eql('http://sferik.github.com/twitter/')
      end
    end
  end

  describe '#assign_aur_details' do
    context 'with nil response' do
      let(:pkgbuild) { described_class.new('mina') }

      it 'sets the epoch to zero' do
        pkgbuild.assign_aur_details(nil)
        expect(pkgbuild.epoch).to eql(0)
      end

      it 'sets the pkgrel to one' do
        pkgbuild.assign_aur_details(nil)
        expect(pkgbuild.pkgrel).to eql(1)
      end

      it 'sleaves the version alone' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(nil)
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.3.7'))
      end
    end

    context 'with equal versions' do
      let(:pkgbuild) { described_class.new('mina') }
      let(:results) do
        { epoch: 1, pkgver: Gem::Version.new('0.3.7'), pkgrel: 1 }
      end

      it 'leaves the epoch alone' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.epoch).to eql(1)
      end

      it 'leaves the version alone' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.3.7'))
      end

      it 'increments the pkgrel' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.pkgrel).to eql(2)
      end
    end

    context 'with pkgver less than version' do
      let(:pkgbuild) { described_class.new('mina') }
      let(:results) do
        { epoch: 1, pkgver: Gem::Version.new('0.3.6'), pkgrel: 2 }
      end

      it 'leaves the epoch alone' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.epoch).to eql(1)
      end

      it 'leaves the version alone' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.3.7'))
      end

      it 'sets the pkgrel to one' do
        pkgbuild.pkgver = Gem::Version.new('0.3.7')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.pkgrel).to eql(1)
      end
    end

    context 'with pkgver greater than version' do
      let(:pkgbuild) { described_class.new('mina') }
      let(:results) do
        { epoch: 1, pkgver: Gem::Version.new('0.3.7'), pkgrel: 2 }
      end

      it 'increments the epoch' do
        pkgbuild.pkgver = Gem::Version.new('0.3.6')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.epoch).to eql(2)
      end

      it 'leaves the version alone' do
        pkgbuild.pkgver = Gem::Version.new('0.3.6')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.3.6'))
      end

      it 'sets the pkgrel to one' do
        pkgbuild.pkgver = Gem::Version.new('0.3.6')
        pkgbuild.assign_aur_details(results)
        expect(pkgbuild.pkgrel).to eql(1)
      end
    end
  end

  describe '.create' do
    context 'with gem mina and no existing pkgbuild' do
      let(:pkgbuild) do
        VCR.use_cassette('pkgbuild_mina') do
          allow(Gembuild).to receive(:configure).and_return(
            name: 'Mario Finelli', email: 'mario@example.com')
          described_class.create('mina')
        end
      end

      it 'returns a pkgbuild' do
        expect(pkgbuild).to be_a(described_class)
      end

      it 'has the correct maintainer' do
        maintainer = 'Mario Finelli <mario at example dot com>'
        expect(pkgbuild.maintainer).to eql(maintainer)
      end

      it 'has the correct architecture' do
        expect(pkgbuild.arch).to eql(['any'])
      end

      it 'has the correct checksum' do
        expect(pkgbuild.checksum).to eql('bd1fa2b56ed1aded882a12f6365a0449' \
                                         '6f5cf8a14c07f8c4f1f3cfc944ef34f6')
      end

      it 'has the correct checksum type' do
        expect(pkgbuild.checksum_type).to eql('sha256')
      end

      it 'has the correct contributor' do
        expect(pkgbuild.contributor).to eql([])
      end

      it 'has the correct dependencies' do
        expect(pkgbuild.depends).to eql(['ruby', 'ruby-open4', 'ruby-rake'])
      end

      it 'has the correct description' do
        description = 'Really fast deployer and server automation tool.'
        expect(pkgbuild.description).to eql(description)
      end

      it 'has the correct epoch' do
        expect(pkgbuild.epoch).to eql(0)
      end

      it 'has the correct gemname' do
        expect(pkgbuild.gemname).to eql('mina')
      end

      it 'has the correct license' do
        expect(pkgbuild.license).to eql([])
      end

      it 'has the correct makedepends' do
        expect(pkgbuild.makedepends).to eql(['rubygems'])
      end

      it 'has the correct noextract' do
        expect(pkgbuild.noextract).to eql(['$_gemname-$pkgver.gem'])
      end

      it 'has the correct options' do
        expect(pkgbuild.options).to eql(['!emptydirs'])
      end

      it 'has the correct pkgname' do
        expect(pkgbuild.pkgname).to eql('ruby-mina')
      end

      it 'has the correct pkgrel' do
        expect(pkgbuild.pkgrel).to eql(2)
      end

      it 'has the correct pkgver' do
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.3.7'))
      end

      it 'has the correct source' do
        url = 'https://rubygems.org/downloads/$_gemname-$pkgver.gem'
        expect(pkgbuild.source).to eql([url])
      end

      it 'has the correct url' do
        expect(pkgbuild.url).to eql('http://github.com/nadarei/mina')
      end
    end

    context 'with gem choice and an existing pkgbuild' do
      let(:pkgbuild_file) do
        File.read(File.join(path_to_fixtures, 'pkgbuild_choice'))
      end

      let(:pkgbuild) do
        VCR.use_cassette('pkgbuild_choice') do
          allow(Gembuild).to receive(:configure).and_return(
            name: 'Mario Finelli', email: 'mario.finelli@yahoo.com')
          described_class.create('choice', pkgbuild_file)
        end
      end

      it 'returns a pkgbuild' do
        expect(pkgbuild).to be_a(described_class)
      end

      it 'has the correct maintainer' do
        maintainer = 'Mario Finelli <mario dot finelli at yahoo dot com>'
        expect(pkgbuild.maintainer).to eql(maintainer)
      end

      it 'has the correct architecture' do
        expect(pkgbuild.arch).to eql(['any'])
      end

      it 'has the correct checksum' do
        expect(pkgbuild.checksum).to eql('a19617f7dfd4921b38a85d0616446620' \
                                         'de685a113ec6d1ecc85bdb67bf38c974')
      end

      it 'has the correct checksum type' do
        expect(pkgbuild.checksum_type).to eql('sha256')
      end

      it 'has the correct contributor' do
        contributor = 'Christopher Eby <kreed at kreed dot org>'
        expect(pkgbuild.contributor).to eql([contributor])
      end

      it 'has the correct dependencies' do
        expect(pkgbuild.depends).to eql(['ruby'])
      end

      it 'has the correct description' do
        description = 'Choice is a simple little gem for easily defining ' \
                      'and parsing command line options with a friendly DSL.'
        expect(pkgbuild.description).to eql(description)
      end

      it 'has the correct epoch' do
        expect(pkgbuild.epoch).to eql(0)
      end

      it 'has the correct gemname' do
        expect(pkgbuild.gemname).to eql('choice')
      end

      it 'has the correct license' do
        expect(pkgbuild.license).to eql(['MIT'])
      end

      it 'has the correct makedepends' do
        expect(pkgbuild.makedepends).to eql(['rubygems'])
      end

      it 'has the correct noextract' do
        expect(pkgbuild.noextract).to eql(['$_gemname-$pkgver.gem'])
      end

      it 'has the correct options' do
        expect(pkgbuild.options).to eql(['!emptydirs'])
      end

      it 'has the correct pkgname' do
        expect(pkgbuild.pkgname).to eql('ruby-choice')
      end

      it 'has the correct pkgrel' do
        expect(pkgbuild.pkgrel).to eql(3)
      end

      it 'has the correct pkgver' do
        expect(pkgbuild.pkgver).to eql(Gem::Version.new('0.2.0'))
      end

      it 'has the correct source' do
        url = 'https://rubygems.org/downloads/$_gemname-$pkgver.gem'
        expect(pkgbuild.source).to eql([url])
      end

      it 'has the correct url' do
        expect(pkgbuild.url).to eql('http://www.github.com/defunkt/choice')
      end
    end
  end

  describe '#render' do
    context 'with gem with no license and no contributors: mina' do
      let(:pkgbuild) do
        VCR.use_cassette('pkgbuild_mina') do
          allow(Gembuild).to receive(:configure).and_return(
            name: 'Mario Finelli', email: 'mario@example.com')
          described_class.create('mina')
        end
      end
      let(:output) { pkgbuild.render }

      it 'returns a string' do
        expect(output).to be_a(String)
      end

      it 'has shameless self-promotion' do
        m = '# Generated with gembuild (https://github.com/mfinelli/gembuild)'
        expect(output).to start_with(m)
      end

      it 'has a maintainer' do
        maintainer = '# Maintainer: Mario Finelli <mario at example dot com>'
        expect(output).to include(maintainer)
      end

      it 'does not have a contributor' do
        expect(output).to_not include('# Contributor')
      end

      it 'has the gem name' do
        expect(output).to include('_gemname=mina')
      end

      it 'has the pkgname' do
        expect(output).to include('pkgname=ruby-$_gemname')
      end

      it 'has the pkgver' do
        expect(output).to include('pkgver=0.3.7')
      end

      it 'has the pkgrel' do
        expect(output).to include('pkgrel=2')
      end

      it 'does not have an epoch' do
        expect(output).to_not include('epoch=')
      end

      it 'has a pkgdesc' do
        desc = 'pkgdesc=\'Really fast deployer and server automation tool.\''
        expect(output).to include(desc)
      end

      it 'has the architecture' do
        expect(output).to include('arch=(\'any\')')
      end

      it 'has the homepage' do
        expect(output).to include('url=\'http://github.com/nadarei/mina\'')
      end

      it 'does not have a license' do
        expect(output).to_not include('license=')
      end

      it 'includes the options' do
        expect(output).to include('options=(!emptydirs)')
      end

      it 'includes the noextract' do
        expect(output).to include('noextract=($_gemname-$pkgver.gem)')
      end

      it 'has the dependencies' do
        depends = 'depends=(\'ruby\' \'ruby-open4\' \'ruby-rake\')'
        expect(output).to include(depends)
      end

      it 'has the makedepends' do
        expect(output).to include('makedepends=(\'rubygems\')')
      end

      it 'has the source' do
        s = 'source=("https://rubygems.org/downloads/$_gemname-$pkgver.gem")'
        expect(output).to include(s)
      end

      it 'has the checksums' do
        sha = 'sha256sums=(\'bd1fa2b56ed1aded882a12f6365a0449' \
              '6f5cf8a14c07f8c4f1f3cfc944ef34f6\')'
        expect(output).to include(sha)
      end

      it 'has the package function' do
        function = "package() {\n  cd \"$srcdir\"\n  local _gemdir=" \
                   "\"$(ruby -e'puts Gem.default_dir')\"\n\n  gem " \
                   'install --ignore-dependencies --no-user-install ' \
                   "-i \"$pkgdir/$_gemdir\" -n \"$pkgdir/usr/bin\" " \
                   "$_gemname-$pkgver.gem\n}"
        expect(output).to include(function)
      end
    end

    context 'with gem with contributors and non-zero epoch: choice' do
      let(:pkgbuild_file) do
        File.read(File.join(path_to_fixtures, 'pkgbuild_choice'))
      end

      let(:pkgbuild) do
        VCR.use_cassette('pkgbuild_choice') do
          allow(Gembuild).to receive(:configure).and_return(
            name: 'Mario Finelli', email: 'mario.finelli@yahoo.com')
          described_class.create('choice', pkgbuild_file)
        end
      end

      let(:output) do
        pkgbuild.epoch = 1
        pkgbuild.render
      end

      it 'returns a string' do
        expect(output).to be_a(String)
      end

      it 'has shameless self-promotion' do
        m = '# Generated with gembuild (https://github.com/mfinelli/gembuild)'
        expect(output).to start_with(m)
      end

      it 'has a maintainer' do
        m = '# Maintainer: Mario Finelli <mario dot finelli at yahoo dot com>'
        expect(output).to include(m)
      end

      it 'has a contributor' do
        c = '# Contributor: Christopher Eby <kreed at kreed dot org>'
        expect(output).to include(c)
      end

      it 'has the gem name' do
        expect(output).to include('_gemname=choice')
      end

      it 'has the pkgname' do
        expect(output).to include('pkgname=ruby-$_gemname')
      end

      it 'has the pkgver' do
        expect(output).to include('pkgver=0.2.0')
      end

      it 'has the pkgrel' do
        expect(output).to include('pkgrel=3')
      end

      it 'has an epoch' do
        expect(output).to include('epoch=1')
      end

      it 'has a pkgdesc' do
        description = 'pkgdesc=\'Choice is a simple little gem for easily ' \
                      'defining and parsing command line options with a ' \
                      'friendly DSL.\''
        expect(output).to include(description)
      end

      it 'has the architecture' do
        expect(output).to include('arch=(\'any\')')
      end

      it 'has the homepage' do
        url = 'url=\'http://www.github.com/defunkt/choice\''
        expect(output).to include(url)
      end

      it 'has a license' do
        expect(output).to include('license=(\'MIT\')')
      end

      it 'includes the options' do
        expect(output).to include('options=(!emptydirs)')
      end

      it 'includes the noextract' do
        expect(output).to include('noextract=($_gemname-$pkgver.gem)')
      end

      it 'has the dependencies' do
        expect(output).to include('depends=(\'ruby\')')
      end

      it 'has the makedepends' do
        expect(output).to include('makedepends=(\'rubygems\')')
      end

      it 'has the source' do
        s = 'source=("https://rubygems.org/downloads/$_gemname-$pkgver.gem")'
        expect(output).to include(s)
      end

      it 'has the checksums' do
        sha = 'sha256sums=(\'a19617f7dfd4921b38a85d0616446620' \
              'de685a113ec6d1ecc85bdb67bf38c974\')'
        expect(output).to include(sha)
      end

      it 'has the package function' do
        function = "package() {\n  cd \"$srcdir\"\n  local _gemdir=" \
                   "\"$(ruby -e'puts Gem.default_dir')\"\n\n  gem " \
                   'install --ignore-dependencies --no-user-install ' \
                   "-i \"$pkgdir/$_gemdir\" -n \"$pkgdir/usr/bin\" " \
                   "$_gemname-$pkgver.gem\n}"
        expect(output).to include(function)
      end
    end
  end

  describe '#write' do
    let(:pkgbuild) do
      VCR.use_cassette('pkgbuild_mina') do
        allow(Gembuild).to receive(:configure).and_return(
          name: 'Mario Finelli', email: 'mario@example.com')
        described_class.create('mina')
      end
    end

    it 'defaults to the current path' do
      expect(File).to receive(:write).with(
        File.join(File.expand_path('.'), 'PKGBUILD'), pkgbuild.render)
      pkgbuild.write
    end

    it 'takes any path' do
      expect(File).to receive(:write).with(
        File::Separator + File.join('tmp', 'pkg', 'PKGBUILD'),
        pkgbuild.render)
      pkgbuild.write('/tmp/pkg')
    end

    it 'expands the path' do
      expect(File).to receive(:write).with(
        File.join(File.expand_path('~'), 'PKGBUILD'), pkgbuild.render)
      pkgbuild.write('~')
    end
  end
end
