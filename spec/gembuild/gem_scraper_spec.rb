# encoding: utf-8

describe Gembuild::GemScraper do
  describe '#initialize' do
    context 'with normal gem name' do
      let(:gem_scraper) { Gembuild::GemScraper.new('netrc') }

      it 'returns a GemScraper instance' do
        expect(gem_scraper).to be_a(Gembuild::GemScraper)
      end

      it 'has a mechanize agent' do
        expect(gem_scraper.agent).to be_a(Mechanize)
      end

      it 'has the gemname set to the parameter' do
        expect(gem_scraper.gemname).to eql('netrc')
      end

      it 'has the correct information url' do
        url = 'https://rubygems.org/api/v1/versions/netrc.json'
        expect(gem_scraper.url).to eql(url)
      end

      it 'has the correct dependency url' do
        url = 'https://rubygems.org/api/v1/dependencies?gems=netrc'
        expect(gem_scraper.deps).to eql(url)
      end

      it 'has the correct frontend url' do
        expect(gem_scraper.gem).to eql('https://rubygems.org/gems/netrc')
      end
    end

    context 'with no gemname' do
      it 'raises an error' do
        ex = Gembuild::UndefinedGemNameError
        expect { Gembuild::GemScraper.new(nil) }.to raise_exception(ex)
      end
    end

    context 'with empty gemname' do
      it 'raises an error' do
        ex = Gembuild::UndefinedGemNameError
        expect { Gembuild::GemScraper.new('') }.to raise_exception(ex)
      end
    end
  end

  describe '#query_latest_version' do
    context 'with normal gem' do
      let(:gem_scraper) { Gembuild::GemScraper.new('netrc') }

      it 'returns a Hash' do
        VCR.use_cassette('gem_scraper_versions_netrc') do
          expect(gem_scraper.query_latest_version).to be_a(Hash)
        end
      end

      it 'returns the correct version' do
        VCR.use_cassette('gem_scraper_versions_netrc') do
          sha = 'de1ce33da8c99ab1d97871726cba7515' \
                '1113f117146becbe45aa85cb3dabee3f'

          expect(gem_scraper.query_latest_version[:sha]).to eql(sha)
        end
      end
    end

    context 'with a prerelease gem' do
      let(:gem_scraper) { Gembuild::GemScraper.new('pry') }

      it 'returns a Hash' do
        VCR.use_cassette('gem_scraper_versions_pry') do
          expect(gem_scraper.query_latest_version).to be_a(Hash)
        end
      end

      it 'returns the correct version' do
        VCR.use_cassette('gem_scraper_versions_pry') do
          expect(gem_scraper.query_latest_version[:number]).to eql('0.10.3')
        end
      end
    end

    context 'with gem that doesn\'t exist' do
      let(:gem_scraper) { Gembuild::GemScraper.new('asdfg') }

      it 'raises an exception' do
        VCR.use_cassette('gem_scraper_versions_asdfg') do
          ex = Gembuild::GemNotFoundError
          expect { gem_scraper.query_latest_version }.to raise_exception(ex)
        end
      end
    end
  end

  describe '#get_version_from_response' do
    context 'with normal gem' do
      let(:gem_scraper) { Gembuild::GemScraper.new('netrc') }

      let(:results) do
        VCR.use_cassette('gem_scraper_versions_netrc') do
          gem_scraper.query_latest_version
        end
      end

      let(:version_from_results) do
        gem_scraper.get_version_from_response(results)
      end

      it 'returns a gem version' do
        expect(version_from_results).to be_a(Gem::Version)
      end

      it 'is the correct version' do
        expect(version_from_results.to_s).to eql('0.11.0')
      end
    end
  end

  describe '#format_description_from_response' do
    context 'with a normal gem' do
      let(:gem_scraper) { Gembuild::GemScraper.new('netrc') }

      let(:results) do
        VCR.use_cassette('gem_scraper_versions_netrc') do
          gem_scraper.query_latest_version
        end
      end

      let(:description_from_results) do
        gem_scraper.format_description_from_response(results)
      end

      let(:expected_description) do
        'This library can read and update netrc files, preserving ' \
        'formatting including comments and whitespace.'
      end

      it 'returns a string' do
        expect(description_from_results).to be_a(String)
      end

      it 'has the correct description' do
        expect(description_from_results).to eql(expected_description)
      end
    end

    context 'with a gem without a description' do
      let(:gem_scraper) { Gembuild::GemScraper.new('git') }

      let(:results) do
        VCR.use_cassette('gem_scraper_versions_git') do
          gem_scraper.query_latest_version
        end
      end

      let(:description) do
        gem_scraper.format_description_from_response(results)
      end

      let(:expected_description) do
        'Ruby/Git is a Ruby library that can be used to create, read and ' \
        'manipulate Git repositories by wrapping system calls to the git ' \
        'binary.'
      end

      it 'is a string' do
        expect(description).to be_a(String)
      end

      it 'has the correct description' do
        expect(description).to eql(expected_description)
      end
    end

    context 'with a gem not ending in a full-stop' do
      let(:gem_scraper) { Gembuild::GemScraper.new('benchmark_suite') }

      let(:results) do
        VCR.use_cassette('gem_scraper_versions_benchmark_suite') do
          gem_scraper.query_latest_version
        end
      end

      let(:description) do
        gem_scraper.format_description_from_response(results)
      end

      let(:expected_description) do
        'A set of enhancements to the standard library benchmark.rb.'
      end

      it 'is a string' do
        expect(description).to be_a(String)
      end

      it 'has the correct description' do
        expect(description).to eql(expected_description)
      end
    end

    context 'with a gem with extra whitespace' do
      let(:gem_scraper) { Gembuild::GemScraper.new('addressable') }

      let(:results) do
        VCR.use_cassette('gem_scraper_versions_addressable') do
          gem_scraper.query_latest_version
        end
      end

      let(:description) do
        gem_scraper.format_description_from_response(results)
      end

      let(:expected_description) do
        'Addressable is a replacement for the URI implementation that is ' \
        'part of Ruby\'s standard library. It more closely conforms to the ' \
        'relevant RFCs and adds support for IRIs and URI templates.'
      end

      it 'is a string' do
        expect(description).to be_a(String)
      end

      it 'has the correct description' do
        expect(description).to eql(expected_description)
      end
    end
  end

  describe '#get_checksum_from_response' do
    context 'with normal gem' do
      let(:gem_scraper) { Gembuild::GemScraper.new('http') }

      let(:results) do
        VCR.use_cassette('gem_scraper_versions_http') do
          gem_scraper.query_latest_version
        end
      end

      let(:sha) do
        '517790c159adc2755c0a6dac5b64d719d4dd8fb4437409e443f4a42b31ea89d2'
      end

      it 'returns the correct sha' do
        expect(gem_scraper.get_checksum_from_response(results)).to eql(sha)
      end
    end
  end

  describe '#get_licenses_from_response' do
    context 'with no license' do
      let(:gem_scraper) { Gembuild::GemScraper.new('mina') }

      let(:results) do
        VCR.use_cassette('gem_scraper_versions_mina') do
          gem_scraper.query_latest_version
        end
      end

      let(:license) { gem_scraper.get_licenses_from_response(results) }

      it 'is an array' do
        expect(license).to be_a(Array)
      end

      it 'is empty' do
        expect(license.count).to be_zero
      end
    end

    context 'with a normal gem' do
      let(:gem_scraper) { Gembuild::GemScraper.new('netrc') }

      let(:results) do
        VCR.use_cassette('gem_scraper_versions_netrc') do
          gem_scraper.query_latest_version
        end
      end

      let(:license) { gem_scraper.get_licenses_from_response(results) }

      it 'is an array' do
        expect(license).to be_a(Array)
      end

      it 'has one license' do
        expect(license.count).to eql(1)
      end

      it 'has the correct license' do
        expect(license).to eql(['MIT'])
      end
    end
  end

  describe '#get_dependencies_for_version' do
    context 'with a gem with dependencies and a string version' do
      let(:gem_scraper) { Gembuild::GemScraper.new('oauth2-client') }

      let(:dependencies_response) do
        VCR.use_cassette('gem_scraper_dependencies_oauth2_client') do
          gem_scraper.get_dependencies_for_version('2.0.0')
        end
      end

      it 'returns an array' do
        expect(dependencies_response).to be_a(Array)
      end

      it 'has the correct dependencies' do
        expect(dependencies_response).to eql(['addressable', 'bcrypt-ruby'])
      end
    end

    context 'with a gem with dependencies and a version version' do
      let(:gem_scraper) { Gembuild::GemScraper.new('httmultiparty') }

      let(:dependencies_response) do
        VCR.use_cassette('gem_scraper_dependencies_httmultiparty') do
          gem_scraper.get_dependencies_for_version(Gem::Version.new('0.3.16'))
        end
      end

      it 'returns an array' do
        expect(dependencies_response).to be_a(Array)
      end

      it 'has the correct dependencies' do
        expect(dependencies_response).to eql(['mimemagic',
                                              'multipart-post',
                                              'httparty'])
      end
    end

    context 'with a gem with no dependencies' do
      let(:gem_scraper) { Gembuild::GemScraper.new('http_parser.rb') }

      let(:dependencies_response) do
        VCR.use_cassette('gem_scraper_dependencies_http_parser_rb') do
          gem_scraper.get_dependencies_for_version(Gem::Version.new('0.6.0'))
        end
      end

      it 'returns an array' do
        expect(dependencies_response).to be_a(Array)
      end

      it 'has no dependencies' do
        expect(dependencies_response.count).to be_zero
      end
    end
  end

  describe '#scrape_frontend_for_homepage_url' do
    context 'with normal gem' do
      let(:gem_scraper) { Gembuild::GemScraper.new('oj') }

      it 'returns the correct homepage' do
        VCR.use_cassette('gem_scraper_frontend_oj') do
          url = 'http://www.ohler.com/oj'
          expect(gem_scraper.scrape_frontend_for_homepage_url).to eql(url)
        end
      end
    end
  end

  describe '#scrape!' do
    context 'with normal gem: netrc' do
      let(:gem_scraper) { Gembuild::GemScraper.new('netrc') }

      let(:results) do
        VCR.use_cassette('gem_scraper_netrc') do
          gem_scraper.scrape!
        end
      end

      it 'returns a hash' do
        expect(results).to be_a(Hash)
      end

      it 'returns all of the correct values' do
        expect(results).to eql(
          version: Gem::Version.new('0.11.0'),
          description: 'This library can read and update netrc files, ' \
            'preserving formatting including comments and whitespace.',
          checksum: 'de1ce33da8c99ab1d97871726cba7515' \
            '1113f117146becbe45aa85cb3dabee3f',
          license: ['MIT'],
          dependencies: [],
          homepage: 'https://github.com/geemus/netrc'
        )
      end
    end

    context 'with normal gem: netrc' do
      let(:gem_scraper) { Gembuild::GemScraper.new('twitter') }
      let(:results) do
        VCR.use_cassette('gem_scraper_twitter') do
          gem_scraper.scrape!
        end
      end

      it 'returns a hash' do
        expect(results).to be_a(Hash)
      end

      it 'returns all of the correct values' do
        expect(results).to eql(
          version: Gem::Version.new('5.15.0'),
          description: 'A Ruby interface to the Twitter API.',
          checksum: '71856f234ab671c26c787f07032ce98a' \
            'cbc345c8fbb3194668f8de14a404bb41',
          license: ['MIT'],
          dependencies: ['simple_oauth', 'naught', 'memoizable', 'json',
                         'http_parser.rb', 'http', 'faraday', 'equalizer',
                         'buftok', 'addressable'],
          homepage: 'http://sferik.github.com/twitter/'
        )
      end
    end
  end
end
