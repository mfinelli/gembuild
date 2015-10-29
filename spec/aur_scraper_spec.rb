# encoding: utf-8

describe Gembuild::AurScraper do
  describe '#initialize' do
    context 'with normal package name' do
      it 'should return an AurScraper instance' do
        expect(Gembuild::AurScraper.new('ruby-mina')).to be_a(Gembuild::AurScraper)
      end

      it 'should have a mechanize agent' do
        expect(Gembuild::AurScraper.new('ruby-mina').agent).to be_a(Mechanize)
      end

      it 'should have the pkgname set to the parameter' do
        expect(Gembuild::AurScraper.new('ruby-mina').pkgname).to eql('ruby-mina')
      end

      it 'should have the correct aur URL' do
        expect(Gembuild::AurScraper.new('ruby-mina').url).to eql('https://aur.archlinux.org/rpc.php?type=info&arg=ruby-mina')
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
end
