# encoding: utf-8

require 'gembuild/pkgbuild'

describe Gembuild::Pkgbuild do
  describe '#initialize' do

    context 'with normal gem name' do
      it 'should be a Pkgbuild' do
        expect(Gembuild::Pkgbuild.new('mechanize')).to be_a(Gembuild::Pkgbuild)
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
