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

      it 'should return a string' do
        VCR.use_cassette('gem_scraper_versions_netrc') do
          expect(gem_scraper.query_latest_version).to be_a(String)
        end
      end

      it 'should return the correct version' do
        VCR.use_cassette('gem_scraper_versions_netrc') do
          expect(gem_scraper.query_latest_version).to eql('0.11.0')
        end
      end
    end
  end
end
