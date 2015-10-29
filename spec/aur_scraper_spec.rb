# encoding: utf-8

describe Gembuild::AurScraper do
  describe '#initialize' do
    context 'with normal package name' do
      let(:aur_scraper) { Gembuild::AurScraper.new('ruby-mina') }

      it 'should return an AurScraper instance' do
        expect(aur_scraper).to be_a(Gembuild::AurScraper)
      end

      it 'should have a mechanize agent' do
        expect(aur_scraper.agent).to be_a(Mechanize)
      end

      it 'should have the pkgname set to the parameter' do
        expect(aur_scraper.pkgname).to eql('ruby-mina')
      end

      it 'should have the correct aur URL' do
        expect(aur_scraper.url).to eql('https://aur.archlinux.org/rpc.php?type=info&arg=ruby-mina')
      end
    end

    context 'with nil package name' do
      it 'should raise an UndefinedPkgnameError' do
        expect { Gembuild::AurScraper.new(nil) }.to raise_exception(Gembuild::UndefinedPkgnameError)
      end
    end
  end

  describe '#query_aur' do
    context 'with package that exists: ruby-mina' do
      let(:aur_scraper) { Gembuild::AurScraper.new('ruby-mina') }

      it 'should return a hash' do
        VCR.use_cassette('aur_scraper_ruby_mina') do
          expect(aur_scraper.query_aur).to be_a(Hash)
        end
      end

      it 'should have symbols for keys' do
        VCR.use_cassette('aur_scraper_ruby_mina') do
          expect(aur_scraper.query_aur.keys).to include(:version, :type, :resultcount, :results)
        end
      end
    end

    context 'with package that does not exist: ruby-asdfg' do
      let(:aur_scraper) { Gembuild::AurScraper.new('ruby-asdfg') }

      it 'should return a hash' do
        VCR.use_cassette('aur_scraper_ruby_asdfg') do
          expect(aur_scraper.query_aur).to be_a(Hash)
        end
      end
    end
  end

  describe '#package_exists?' do
    context 'with package that exists: ruby-mina' do
      let(:aur_scraper) { Gembuild::AurScraper.new('ruby-mina') }

      it 'should return true' do
        VCR.use_cassette('aur_scraper_ruby_mina') do
          expect(aur_scraper.package_exists?(aur_scraper.query_aur)).to eql(true)
        end
      end
    end

    context 'with package that does not exist: ruby-asdfg' do
      let(:aur_scraper) { Gembuild::AurScraper.new('ruby-asdfg') }

      it 'should return false' do
        VCR.use_cassette('aur_scraper_ruby_asdfg') do
          expect(aur_scraper.package_exists?(aur_scraper.query_aur)).to eql(false)
        end
      end
    end
  end

  describe '#get_version_hash' do
    context 'with package with no epoch' do
      let(:aur_scraper) { Gembuild::AurScraper.new('ruby-mina') }
      let(:results) {
        VCR.use_cassette('aur_scraper_ruby_mina') do
          aur_scraper.get_version_hash(aur_scraper.query_aur)
        end
      }

      it 'should return a hash' do
        expect(results).to be_a(Hash)
      end

      it 'should have no epoch' do
        expect(results[:epoch]).to eql(0)
      end

      it 'should have the right version' do
        expect(results[:pkgver]).to eql('0.3.7')
      end

      it 'should have the right release' do
        expect(results[:pkgrel]).to eql(1)
      end

      it 'should only have three values' do
        expect(results.keys.count).to eql(3)
      end
    end

    context 'with package with an epoch' do
      let(:aur_scraper) { Gembuild::AurScraper.new('vim-puppet') }
      let(:results) {
        VCR.use_cassette('aur_scraper_vim_puppet') do
          aur_scraper.get_version_hash(aur_scraper.query_aur)
        end
      }

      it 'should return a hash' do
        expect(results).to be_a(Hash)
      end

      it 'should have no epoch' do
        expect(results[:epoch]).to eql(1)
      end

      it 'should have the right version' do
        expect(results[:pkgver]).to eql('4.2.1')
      end

      it 'should have the right release' do
        expect(results[:pkgrel]).to eql(1)
      end

      it 'should only have three values' do
        expect(results.keys.count).to eql(3)
      end
    end
  end

  describe '#scrape!' do
    context 'with package that exists' do
      let(:aur_scraper) { Gembuild::AurScraper.new('ruby-mina') }
      let(:results) {
        VCR.use_cassette('aur_scraper_ruby_mina') do
          aur_scraper.scrape!
        end
      }

      it 'should return a hash' do
        expect(results).to be_a(Hash)
      end

      it 'should have the correct results' do
        expect(results).to eql({ epoch: 0, pkgver: '0.3.7', pkgrel: 1 })
      end
    end

    context 'with package that doesn\'t exist' do
      let(:aur_scraper) { Gembuild::AurScraper.new('ruby-asdfg') }
      let(:results) {
        VCR.use_cassette('aur_scraper_ruby_asdfg') do
          aur_scraper.scrape!
        end
      }

      it 'should return a hash' do
        expect(results).to be_nil
      end
    end
  end
end
