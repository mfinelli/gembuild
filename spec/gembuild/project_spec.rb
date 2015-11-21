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

  describe '#configure_git!' do
    it 'should call git config commands' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
      expect_any_instance_of(Gembuild::Project).to receive(:`).with('cd /tmp/pkg/ruby-mina && git config user.name "Mario Finelli"')
      expect_any_instance_of(Gembuild::Project).to receive(:`).with('cd /tmp/pkg/ruby-mina && git config user.email "mario@example.com"')
      Gembuild::Project.new('mina').configure_git!('Mario Finelli', 'mario@example.com')
    end
  end

  describe '#stage_changes!' do
    it 'should call shell commands' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
      expect_any_instance_of(Gembuild::Project).to receive(:`).with('cd /tmp/pkg/ruby-mina && mksrcinfo && git add .')
      Gembuild::Project.new('mina').stage_changes!
    end
  end

  describe '#commit_changes!' do
    it 'should call shell commands' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
      expect_any_instance_of(Gembuild::Project).to receive(:`).with('cd /tmp/pkg/ruby-mina && git commit -m "test message"')
      Gembuild::Project.new('mina').commit_changes!('test message')
    end
  end

  describe '#load_existing_pkgbuild' do
    context 'with an existing pkgbuild' do
      it 'should return a string' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow(File).to receive(:file?).with('/tmp/pkg/ruby-mina/PKGBUILD').and_return(true)
        allow(File).to receive(:read).with('/tmp/pkg/ruby-mina/PKGBUILD').and_return('test pkgbuild')
        expect(Gembuild::Project.new('mina').load_existing_pkgbuild).to be_a(String)
      end

      it 'should return the existing pkgbuild' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow(File).to receive(:file?).with('/tmp/pkg/ruby-mina/PKGBUILD').and_return(true)
        allow(File).to receive(:read).with('/tmp/pkg/ruby-mina/PKGBUILD').and_return('test pkgbuild')
        expect(Gembuild::Project.new('mina').load_existing_pkgbuild).to eql('test pkgbuild')
      end
    end

    context 'with no existing pkgbuild' do
      it 'should return a string' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow(File).to receive(:file?).with('/tmp/pkg/ruby-mina/PKGBUILD').and_return(false)
        expect(File).to_not receive(:read)
        expect(Gembuild::Project.new('mina').load_existing_pkgbuild).to be_a(String)
      end

      it 'should return an empty string' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow(File).to receive(:file?).with('/tmp/pkg/ruby-mina/PKGBUILD').and_return(false)
        expect(File).to_not receive(:read)
        expect(Gembuild::Project.new('mina').load_existing_pkgbuild).to eql('')
      end
    end
  end

  describe '#commit_message' do
    context 'with first commit' do
      it 'should return initial commit' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow_any_instance_of(Gembuild::Project).to receive(:`).with('cd /tmp/pkg/ruby-mina && git rev-parse HEAD &> /dev/null')
        allow($CHILD_STATUS).to receive(:success?).and_return(false)
        expect(Gembuild::Project.new('mina').commit_message(Gem::Version.new('0.3.7'))).to eql('Initial commit')
      end
    end

    context 'with other commits' do
      it 'should return bump to version' do
        allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg'})
        allow_any_instance_of(Gembuild::Project).to receive(:`).with('cd /tmp/pkg/ruby-mina && git rev-parse HEAD &> /dev/null')
        allow($CHILD_STATUS).to receive(:success?).and_return(true)
        expect(Gembuild::Project.new('mina').commit_message(Gem::Version.new('0.3.7'))).to eql('Bump version to 0.3.7')
      end
    end
  end

  describe '#prepare_working_directory!' do
    it 'should call all of the prepare methods' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg', name: 'Test', email: 'test@example.com'})
      expect_any_instance_of(Gembuild::Project).to receive(:ensure_pkgdir!)
      expect_any_instance_of(Gembuild::Project).to receive(:clone_and_update!)
      expect_any_instance_of(Gembuild::Project).to receive(:write_gitignore!)
      expect_any_instance_of(Gembuild::Project).to receive(:configure_git!).with('Test', 'test@example.com')
      Gembuild::Project.new('mina').prepare_working_directory!
    end
  end

  describe '#clone_and_commit!' do
    it 'should make all of the method calls' do
      allow(Gembuild).to receive(:configure).and_return({pkgdir: '/tmp/pkg', name: 'Test', email: 'test@example.com'})
      expect_any_instance_of(Gembuild::Project).to receive(:prepare_working_directory!)
      expect(Gembuild::Pkgbuild).to receive(:create).and_return(Gembuild::Pkgbuild.new('mina'))
      expect_any_instance_of(Gembuild::Pkgbuild).to receive(:write)
      expect_any_instance_of(Gembuild::Project).to receive(:stage_changes!)
      expect_any_instance_of(Gembuild::Project).to receive(:commit_changes!)
      expect_any_instance_of(Gembuild::Project).to receive(:commit_message)
      Gembuild::Project.new('mina').clone_and_commit!
    end
  end
end
