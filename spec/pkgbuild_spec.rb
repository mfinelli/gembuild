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
end
