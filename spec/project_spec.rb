# encoding: utf-8

describe Gembuild::Project do
  describe '#initialize' do
    it 'should return a project' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
      allow(File).to receive(:directory?).and_return(true)
      expect(Gembuild::Project.new('mina')).to be_a(Gembuild::Project)
    end

    it 'should have the ruby project name' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
      allow(File).to receive(:directory?).and_return(true)
      expect(Gembuild::Project.new('mina').pkgname).to eql('ruby-mina')
    end

    it 'should have the correct pkgdir' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
      allow(File).to receive(:directory?).and_return(true)
      expect(Gembuild::Project.new('mina').pkgdir).to eql('/tmp/pkg')
    end
  end

  describe '#ensure_pkgdir' do
    context 'with directory that exists' do
      it 'should not try to create the pkgdir' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow(File).to receive(:directory?).and_return(true)
        expect(FileUtils).to_not receive(:mkdir_p)
        Gembuild::Project.new('mina')
      end
    end

    context 'with directory that does not exist' do
      it 'should try to create the pkgdir' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow(File).to receive(:directory?).and_return(false)
        expect(FileUtils).to receive(:mkdir_p).with('/tmp/pkg')
        Gembuild::Project.new('mina')
      end
    end
  end
end
