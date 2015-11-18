# encoding: utf-8

describe Gembuild::Project do
  describe '#initialize' do
    it 'should return a project' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
      expect(Gembuild::Project.new('mina')).to be_a(Gembuild::Project)
    end

    it 'should have the ruby project name' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
      expect(Gembuild::Project.new('mina').pkgname).to eql('ruby-mina')
    end

    it 'should have the name' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
      expect(Gembuild::Project.new('mina').gemname).to eql('mina')
    end

    it 'should have the correct pkgdir' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
      expect(Gembuild::Project.new('mina').pkgdir).to eql('/tmp/pkg')
    end

    it 'should have the correct config' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
      expect(Gembuild::Project.new('mina').config).to eql({pkgdir: '/tmp/pkg'})
    end

    it 'should have the correct full path' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
      expect(Gembuild::Project.new('mina').full_path).to eql('/tmp/pkg/ruby-mina')
    end
  end

  describe '#ensure_pkgdir' do
    context 'with directory that exists' do
      it 'should not try to create the pkgdir' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow(File).to receive(:directory?).and_return(true)
        expect(FileUtils).to_not receive(:mkdir_p)
        Gembuild::Project.new('mina').ensure_pkgdir!
      end
    end

    context 'with directory that does not exist' do
      it 'should try to create the pkgdir' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow(File).to receive(:directory?).and_return(false)
        expect(FileUtils).to receive(:mkdir_p).with('/tmp/pkg')
        Gembuild::Project.new('mina').ensure_pkgdir!
      end
    end
  end

  describe '#write_gitignore!' do
    context 'with existing gitignore file' do
      it 'should not write a file' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow(File).to receive(:exist?).with('/tmp/pkg/ruby-mina/.gitignore').and_return(true)
        expect(File).to_not receive(:write)
        Gembuild::Project.new('mina').write_gitignore!
      end
    end

    context 'with no gitignore file' do
      it 'should write a file' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow(File).to receive(:exist?).with('/tmp/pkg/ruby-mina/.gitignore').and_return(false)
        expect(File).to receive(:write).with('/tmp/pkg/ruby-mina/.gitignore', Gembuild::Project::GITIGNORE)
        Gembuild::Project.new('mina').write_gitignore!
      end
    end
  end

  describe '#clone_and_update!' do
    context 'with existing directory' do
      it 'should update the master branch' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow(File).to receive(:directory?).with('/tmp/pkg/ruby-mina').and_return(true)
        expect_any_instance_of(Gembuild::Project).to receive(:`).with('cd /tmp/pkg/ruby-mina && git checkout master && git pull origin master')
        Gembuild::Project.new('mina').clone_and_update!
      end
    end

    context 'with non-existing directory' do
      it 'should clone the repository' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow(File).to receive(:directory?).with('/tmp/pkg/ruby-mina').and_return(false)
        expect_any_instance_of(Gembuild::Project).to receive(:`).with('git clone ssh://aur@aur4.archlinux.org/ruby-mina.git /tmp/pkg/ruby-mina')
        Gembuild::Project.new('mina').clone_and_update!
      end
    end
  end
end
