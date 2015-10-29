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
        expect{Gembuild::AurScraper.new(nil)}.to raise_exception(Gembuild::UndefinedPkgnameError)
      end
    end
  end
end
