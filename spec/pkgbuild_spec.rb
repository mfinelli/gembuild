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
        expect(pkgbuild.contributor).to be_nil
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
    end

  end
end
