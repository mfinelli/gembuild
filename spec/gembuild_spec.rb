# encoding: utf-8

describe Gembuild do
  describe '.conf_file' do
    it 'should return .gembuild in the home directory' do
      expect(Gembuild.conf_file).to eql(File.join(File.expand_path('~'), '.gembuild'))
    end
  end

  describe '.prompt_for_confirmation' do
    context 'with unimportant input' do
      it 'should output the detected value' do
        expect(STDOUT).to receive(:puts).with('Detected "test", is this correct? (y/n)')
        allow(Gembuild).to receive(:gets) { "Yes\n" }
        Gembuild.prompt_for_confirmation('test')
      end

      it 'should return a boolean' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { "Yes\n" }
        expect(Gembuild.prompt_for_confirmation('test')).to be_truthy
      end
    end

    context 'with negative uppercase response' do
      it 'should return false' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { "No\n" }
        expect(Gembuild.prompt_for_confirmation('test')).to eql(false)
      end
    end

    context 'with negative lowercase response' do
      it 'should return false' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { "n\n" }
        expect(Gembuild.prompt_for_confirmation('test')).to eql(false)
      end
    end

    context 'with affermative uppercase response' do
      it 'should return true' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { "Y\n" }
        expect(Gembuild.prompt_for_confirmation('test')).to eql(true)
      end
    end

    context 'with affermative lowercase response' do
      it 'should return true' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { "yes\n" }
        expect(Gembuild.prompt_for_confirmation('test')).to eql(true)
      end
    end

    context 'with invalid response' do
      it 'should return false' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { "AAA\n" }
        expect(Gembuild.prompt_for_confirmation('test')).to eql(false)
      end
    end
  end

  describe '.prompt_for_git_name' do
    context 'with message' do
      it 'should display the message' do
        expect(STDOUT).to receive(:puts).with('Test Message')
        expect(STDOUT).to receive(:puts).with('Please enter desired name: ')
        allow(Gembuild).to receive(:gets) { "test\n" }
        Gembuild.prompt_for_git_name('Test Message')
      end

      it 'should return what was entered' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { "My Name\n" }
        expect(Gembuild.prompt_for_git_name('Test Message')).to eql('My Name')
      end
    end

    context 'with no message' do
      it 'should only display the enter message' do
        expect(STDOUT).to receive(:puts).with('Please enter desired name: ')
        allow(Gembuild).to receive(:gets) { "test\n" }
        Gembuild.prompt_for_git_name
      end

      it 'should return what was entered' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { "Another Name\n" }
        expect(Gembuild.prompt_for_git_name).to eql('Another Name')
      end
    end

    context 'with empty message' do
      it 'should only display the enter message' do
        expect(STDOUT).to receive(:puts).with('Please enter desired name: ')
        allow(Gembuild).to receive(:gets) { "test\n" }
        Gembuild.prompt_for_git_name('')
      end
    end
  end

  describe '.prompt_for_git_email' do
    context 'with message' do
      it 'should display the message' do
        expect(STDOUT).to receive(:puts).with('Test Email Message')
        expect(STDOUT).to receive(:puts).with('Please enter desired email: ')
        allow(Gembuild).to receive(:gets) { "test\n" }
        Gembuild.prompt_for_git_email('Test Email Message')
      end

      it 'should return what was entered' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { "me@example.com\n" }
        expect(Gembuild.prompt_for_git_email('Test Email Message')).to eql('me@example.com')
      end
    end

    context 'with no message' do
      it 'should only display the enter message' do
        expect(STDOUT).to receive(:puts).with('Please enter desired email: ')
        allow(Gembuild).to receive(:gets) { "test\n" }
        Gembuild.prompt_for_git_email
      end

      it 'should return what was entered' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { "me@example.org\n" }
        expect(Gembuild.prompt_for_git_email).to eql('me@example.org')
      end
    end

    context 'with empty message' do
      it 'should only display the enter message' do
        expect(STDOUT).to receive(:puts).with('Please enter desired email: ')
        allow(Gembuild).to receive(:gets) { "test\n" }
        Gembuild.prompt_for_git_email('')
      end
    end
  end

  describe '.fetch_git_global_name' do
    context 'with successful call to git and confirmation' do
      it 'should return the value from git' do
        allow_message_expectations_on_nil
        expect(Gembuild).to receive(:`).with('git config --global user.name').and_return('A Name')
        allow($CHILD_STATUS).to receive(:success?).and_return(true)
        expect(STDOUT).to receive(:puts).with('Detected "A Name", is this correct? (y/n)')
        allow(Gembuild).to receive(:gets) { "y\n" }
        expect(Gembuild.fetch_git_global_name).to eql('A Name')
      end
    end

    context 'with successful call to git and negation' do
      it 'should return the value entered' do
        allow_message_expectations_on_nil
        expect(Gembuild).to receive(:`).with('git config --global user.name').and_return('Bad Name')
        allow($CHILD_STATUS).to receive(:success?).and_return(true)
        expect(STDOUT).to receive(:puts).with('Detected "Bad Name", is this correct? (y/n)')
        allow(Gembuild).to receive(:gets) { "n\n" }
        expect(STDOUT).to receive(:puts).with('Please enter desired name: ')
        allow(Gembuild).to receive(:gets) { "New name" }
        expect(Gembuild.fetch_git_global_name).to eql('New name')
      end
    end

    context 'with a failure call to git' do
      it 'should return the value entered' do
        allow_message_expectations_on_nil
        expect(Gembuild).to receive(:`).with('git config --global user.name').and_return('Fail Name')
        allow($CHILD_STATUS).to receive(:success?).and_return(false)
        expect(STDOUT).to receive(:puts).with('Could not detect name from git configuration.')
        expect(STDOUT).to receive(:puts).with('Please enter desired name: ')
        allow(Gembuild).to receive(:gets) { "A Name After Failure\n" }
        expect(Gembuild.fetch_git_global_name).to eql('A Name After Failure')
      end
    end
  end

  describe '.fetch_git_global_email' do
    context 'with successful call to git and confirmation' do
      it 'should return the value from git' do
        allow_message_expectations_on_nil
        expect(Gembuild).to receive(:`).with('git config --global user.email').and_return('my@email.com')
        allow($CHILD_STATUS).to receive(:success?).and_return(true)
        expect(STDOUT).to receive(:puts).with('Detected "my@email.com", is this correct? (y/n)')
        allow(Gembuild).to receive(:gets) { "y\n" }
        expect(Gembuild.fetch_git_global_email).to eql('my@email.com')
      end
    end

    context 'with successful call to git and negation' do
      it 'should return the value entered' do
        allow_message_expectations_on_nil
        expect(Gembuild).to receive(:`).with('git config --global user.email').and_return('bad@email.com')
        allow($CHILD_STATUS).to receive(:success?).and_return(true)
        expect(STDOUT).to receive(:puts).with('Detected "bad@email.com", is this correct? (y/n)')
        allow(Gembuild).to receive(:gets) { "n\n" }
        expect(STDOUT).to receive(:puts).with('Please enter desired email: ')
        allow(Gembuild).to receive(:gets) { "new@email.com" }
        expect(Gembuild.fetch_git_global_email).to eql('new@email.com')
      end
    end

    context 'with a failure call to git' do
      it 'should return the value entered' do
        allow_message_expectations_on_nil
        expect(Gembuild).to receive(:`).with('git config --global user.email').and_return('fail@email.com')
        allow($CHILD_STATUS).to receive(:success?).and_return(false)
        expect(STDOUT).to receive(:puts).with('Could not detect email from git configuration.')
        expect(STDOUT).to receive(:puts).with('Please enter desired email: ')
        allow(Gembuild).to receive(:gets) { "good@email.com\n" }
        expect(Gembuild.fetch_git_global_email).to eql('good@email.com')
      end
    end
  end

  describe '.fetch_pkgdir' do
    it 'should prompt the user for the directory' do
      expect(STDOUT).to receive(:puts).with('Where should projects be checked out?')
      allow(Gembuild).to receive(:gets) { "test\n" }
      Gembuild.fetch_pkgdir
    end

    it 'should return the value entered' do
      expect(STDOUT).to receive(:puts)
      allow(Gembuild).to receive(:gets) { '/tmp/packages' }
      expect(Gembuild.fetch_pkgdir).to eql('/tmp/packages')
    end

    it 'should expand the given path' do
      expect(STDOUT).to receive(:puts)
      allow(Gembuild).to receive(:gets) { '~/packages' }
      expect(Gembuild.fetch_pkgdir).to eql(File.expand_path('~/packages'))
    end
  end

  describe '.configure' do
    context 'with normal behavior' do
      it 'should respond to configure' do
        expect(Gembuild).to respond_to(:configure)
      end
    end

    context 'with existing configuration' do
      it 'shoudl return a hash' do
        allow(File).to receive(:file?).and_return(true)
        allow(YAML).to receive(:load_file).and_return({name: 'Mario Finelli', email: 'mario@example.com', pkgdir: '/tmp/packages'})

        expect(Gembuild.configure).to be_a(Hash)
      end

      it 'should return the correct configuration' do
        allow(File).to receive(:file?).and_return(true)
        allow(YAML).to receive(:load_file).and_return({name: 'Mario Finelli', email: 'mario@example.com', pkgdir: '/tmp/packages'})

        expect(Gembuild.configure).to eql({name: 'Mario Finelli', email: 'mario@example.com', pkgdir: '/tmp/packages'})
      end
    end

    context 'with no existing configuration' do
      it 'should ask the user name' do
        allow(File).to receive(:file?).and_return(false)
        allow(Gembuild).to receive(:fetch_git_global_email)
        allow(Gembuild).to receive(:fetch_pkgdir)
        expect(Gembuild).to receive(:fetch_git_global_name)
        Gembuild.configure
      end

      it 'should ask the user email' do
        allow(File).to receive(:file?).and_return(false)
        allow(Gembuild).to receive(:fetch_git_global_name)
        allow(Gembuild).to receive(:fetch_pkgdir)
        expect(Gembuild).to receive(:fetch_git_global_email)
        Gembuild.configure
      end

      it 'should ask the user where to store directories' do
        allow(File).to receive(:file?).and_return(false)
        allow(Gembuild).to receive(:fetch_git_global_name)
        allow(Gembuild).to receive(:fetch_git_global_email)
        expect(Gembuild).to receive(:fetch_pkgdir)
        Gembuild.configure
      end

      it 'should write a new configuration file' do
        allow(File).to receive(:file?).and_return(false)
        allow(Gembuild).to receive(:fetch_git_global_name).and_return('Mario Finelli')
        allow(Gembuild).to receive(:fetch_git_global_email).and_return('mario@example.com')
        allow(Gembuild).to receive(:fetch_pkgdir).and_return('/tmp/aur-packages')
        allow(YAML).to receive(:load_file)
        expect(File).to receive(:write).with(Gembuild.conf_file, File.read(File.join(File.dirname(__FILE__), 'fixtures', 'configuration.yml')))
        Gembuild.configure
      end

      it 'should return the correct configuration' do
        allow(File).to receive(:file?).and_return(false)
        allow(Gembuild).to receive(:fetch_git_global_name).and_return('Mario Finelli')
        allow(Gembuild).to receive(:fetch_git_global_email).and_return('mario@example.com')
        allow(Gembuild).to receive(:fetch_pkgdir).and_return('/tmp/aur-packages')
        allow(File).to receive(:write)
        allow(YAML).to receive(:load_file).and_return(YAML.load_file(File.join(File.dirname(__FILE__), 'fixtures', 'configuration.yml')))
        expect(Gembuild.configure).to eql(YAML.load_file(File.join(File.dirname(__FILE__), 'fixtures', 'configuration.yml')))
      end
    end
  end
end
