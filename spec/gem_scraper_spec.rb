# encoding: utf-8

describe Gembuild::GemScraper do
  describe '#initialize' do
    context 'with normal gem name' do
      let(:gem_scraper) { Gembuild::GemScraper.new('netrc') }

      it 'should return a GemScraper instance' do
        expect(gem_scraper).to be_a(Gembuild::GemScraper)
      end

      it 'should have a mechanize agent' do
        expect(gem_scraper.agent).to be_a(Mechanize)
      end

      it 'should have the gemname set to the parameter' do
        expect(gem_scraper.gemname).to eql('netrc')
      end

      it 'should have the correct information url' do
        expect(gem_scraper.url).to eql('https://rubygems.org/api/v1/versions/netrc.json')
      end

      it 'should have the correct dependency url' do
        expect(gem_scraper.deps).to eql('https://rubygems.org/api/v1/dependencies?gems=netrc')
      end

      it 'should have the correct frontend url' do
        expect(gem_scraper.gem).to eql('https://rubygems.org/gems/netrc')
      end
    end

    context 'with no gemname' do
      it 'should raise an error' do
        expect { Gembuild::GemScraper.new(nil) }.to raise_exception(Gembuild::UndefinedGemNameError)
      end
    end
  end

  describe '#query_latest_version' do
    context 'with normal gem' do
      let(:gem_scraper) { Gembuild::GemScraper.new('netrc') }

      it 'should return a Hash' do
        VCR.use_cassette('gem_scraper_versions_netrc') do
          expect(gem_scraper.query_latest_version).to be_a(Hash)
        end
      end

      it 'should return the correct version' do
        VCR.use_cassette('gem_scraper_versions_netrc') do
          expect(gem_scraper.query_latest_version[:sha]).to eql('de1ce33da8c99ab1d97871726cba75151113f117146becbe45aa85cb3dabee3f')
        end
      end
    end

    context 'with a prerelease gem' do
      let(:gem_scraper) { Gembuild::GemScraper.new('pry') }

      it 'should return a Hash' do
        VCR.use_cassette('gem_scraper_versions_pry') do
          expect(gem_scraper.query_latest_version).to be_a(Hash)
        end
      end

      it 'should return the correct version' do
        VCR.use_cassette('gem_scraper_versions_pry') do
          expect(gem_scraper.query_latest_version[:number]).to eql('0.10.3')
        end
      end
    end

    context 'with gem that doesn\'t exist' do
      let(:gem_scraper) { Gembuild::GemScraper.new('asdfg') }

      it 'should raise an exception' do
        VCR.use_cassette('gem_scraper_versions_asdfg') do
          expect { gem_scraper.query_latest_version }.to raise_exception(Gembuild::GemNotFoundError)
        end
      end
    end
  end

  describe '#get_version_from_response' do
    context 'with normal gem' do
      let(:gem_scraper) { Gembuild::GemScraper.new('netrc') }
      let(:results) {
        VCR.use_cassette('gem_scraper_versions_netrc') do
          gem_scraper.query_latest_version
        end
      }

      it 'should return a gem version' do
        expect(gem_scraper.get_version_from_response(results)).to be_a(Gem::Version)
      end

      it 'should be the correct version' do
        expect(gem_scraper.get_version_from_response(results).to_s).to eql('0.11.0')
      end
    end
  end

  describe '#format_description_from_response' do
    context 'with a normal gem' do
      let(:gem_scraper) { Gembuild::GemScraper.new('netrc') }
      let(:results) {
        VCR.use_cassette('gem_scraper_versions_netrc') do
          gem_scraper.query_latest_version
        end
      }

      it 'should return a string' do
        expect(gem_scraper.format_description_from_response(results)).to be_a(String)
      end

      it 'should have the correct description' do
        expect(gem_scraper.format_description_from_response(results)).to eql('This library can read and update netrc files, preserving formatting including comments and whitespace.')
      end
    end

    context 'with a gem without a description' do
      let(:gem_scraper) { Gembuild::GemScraper.new('git') }
      let(:results) {
        VCR.use_cassette('gem_scraper_versions_git') do
          gem_scraper.query_latest_version
        end
      }
      let(:description) { gem_scraper.format_description_from_response(results) }

      it 'should be a string' do
        expect(description).to be_a(String)
      end

      it 'should have the correct description' do
        expect(description).to eql('Ruby/Git is a Ruby library that can be used to create, read and manipulate Git repositories by wrapping system calls to the git binary.')
      end
    end

    context 'with a gem not ending in a full-stop' do
      let(:gem_scraper) { Gembuild::GemScraper.new('benchmark_suite') }
      let(:results) {
        VCR.use_cassette('gem_scraper_versions_benchmark_suite') do
          gem_scraper.query_latest_version
        end
      }
      let(:description) { gem_scraper.format_description_from_response(results) }

      it 'should be a string' do
        expect(description).to be_a(String)
      end

      it 'should have the correct description' do
        expect(description).to eql('A set of enhancements to the standard library benchmark.rb.')
      end
    end

    context 'with a gem with extra whitespace' do
      let(:gem_scraper) { Gembuild::GemScraper.new('addressable') }
      let(:results) {
        VCR.use_cassette('gem_scraper_versions_addressable') do
          gem_scraper.query_latest_version
        end
      }
      let(:description) { gem_scraper.format_description_from_response(results) }

      it 'should be a string' do
        expect(description).to be_a(String)
      end

      it 'should have the correct description' do
        expect(description).to eql('Addressable is a replacement for the URI implementation that is part of Ruby\'s standard library. It more closely conforms to the relevant RFCs and adds support for IRIs and URI templates.')
      end
    end
  end

  describe '#get_checksum_from_response' do
    context 'with normal gem' do
      let(:gem_scraper) { Gembuild::GemScraper.new('http') }
      let(:results) {
        VCR.use_cassette('gem_scraper_versions_http') do
          gem_scraper.query_latest_version
        end
      }

      it 'should return the correct sha' do
        expect(gem_scraper.get_checksum_from_response(results)).to eql('517790c159adc2755c0a6dac5b64d719d4dd8fb4437409e443f4a42b31ea89d2')
      end
    end
  end
end
