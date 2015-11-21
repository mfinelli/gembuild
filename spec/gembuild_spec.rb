# encoding: utf-8

describe Gembuild do
  describe '.conf_file' do
    it 'returns .gembuild in the home directory' do
      expect(described_class.conf_file).to eql(File.join(
                                                 File.expand_path('~'),
                                                 '.gembuild'))
    end
  end

  describe '.prompt_for_confirmation' do
    context 'with unimportant input' do
      it 'outputs the detected value' do
        output = 'Detected "test", is this correct? (y/n)'
        expect(STDOUT).to receive(:puts).with(output)
        allow(described_class).to receive(:gets) { "Yes\n" }
        described_class.prompt_for_confirmation('test')
      end

      it 'returns a boolean' do
        allow(STDOUT).to receive(:puts)
        allow(described_class).to receive(:gets) { "Yes\n" }
        expect(described_class.prompt_for_confirmation('test')).to be_truthy
      end
    end

    context 'with negative uppercase response' do
      it 'returns false' do
        allow(STDOUT).to receive(:puts)
        allow(described_class).to receive(:gets) { "No\n" }
        expect(described_class.prompt_for_confirmation('test')).to eql(false)
      end
    end

    context 'with negative lowercase response' do
      it 'returns false' do
        allow(STDOUT).to receive(:puts)
        allow(described_class).to receive(:gets) { "n\n" }
        expect(described_class.prompt_for_confirmation('test')).to eql(false)
      end
    end

    context 'with affermative uppercase response' do
      it 'returns true' do
        allow(STDOUT).to receive(:puts)
        allow(described_class).to receive(:gets) { "Y\n" }
        expect(described_class.prompt_for_confirmation('test')).to eql(true)
      end
    end

    context 'with affermative lowercase response' do
      it 'returns true' do
        allow(STDOUT).to receive(:puts)
        allow(described_class).to receive(:gets) { "yes\n" }
        expect(described_class.prompt_for_confirmation('test')).to eql(true)
      end
    end

    context 'with invalid response' do
      it 'returns false' do
        allow(STDOUT).to receive(:puts)
        allow(described_class).to receive(:gets) { "AAA\n" }
        expect(described_class.prompt_for_confirmation('test')).to eql(false)
      end
    end
  end

  describe '.prompt_for_git_name' do
    context 'with message' do
      it 'displays the message' do
        expect(STDOUT).to receive(:puts).with('Test Message')
        expect(STDOUT).to receive(:puts).with('Please enter desired name: ')
        allow(described_class).to receive(:gets) { "test\n" }
        described_class.prompt_for_git_name('Test Message')
      end

      it 'returns what was entered' do
        e = 'My Name'
        allow(STDOUT).to receive(:puts)
        allow(described_class).to receive(:gets) { "My Name\n" }
        expect(described_class.prompt_for_git_name('Test Message')).to eql(e)
      end
    end

    context 'with no message' do
      it 'only displays the entered message' do
        expect(STDOUT).to receive(:puts).with('Please enter desired name: ')
        allow(described_class).to receive(:gets) { "test\n" }
        described_class.prompt_for_git_name
      end

      it 'returns what was entered' do
        allow(STDOUT).to receive(:puts)
        allow(described_class).to receive(:gets) { "Another Name\n" }
        expect(described_class.prompt_for_git_name).to eql('Another Name')
      end
    end

    context 'with empty message' do
      it 'only displays the enter message' do
        expect(STDOUT).to receive(:puts).with('Please enter desired name: ')
        allow(described_class).to receive(:gets) { "test\n" }
        described_class.prompt_for_git_name('')
      end
    end
  end

  describe '.prompt_for_git_email' do
    context 'with message' do
      it 'displays the message' do
        expect(STDOUT).to receive(:puts).with('Test Email Message')
        expect(STDOUT).to receive(:puts).with('Please enter desired email: ')
        allow(described_class).to receive(:gets) { "test\n" }
        described_class.prompt_for_git_email('Test Email Message')
      end

      it 'returns what was entered' do
        e = 'me@example.com'
        allow(STDOUT).to receive(:puts)
        allow(described_class).to receive(:gets) { "me@example.com\n" }
        expect(described_class.prompt_for_git_email('test message')).to eql(e)
      end
    end

    context 'with no message' do
      it 'only displays the enter message' do
        expect(STDOUT).to receive(:puts).with('Please enter desired email: ')
        allow(described_class).to receive(:gets) { "test\n" }
        described_class.prompt_for_git_email
      end

      it 'returns what was entered' do
        allow(STDOUT).to receive(:puts)
        allow(described_class).to receive(:gets) { "me@example.org\n" }
        expect(described_class.prompt_for_git_email).to eql('me@example.org')
      end
    end

    context 'with empty message' do
      it 'only displays the enter message' do
        expect(STDOUT).to receive(:puts).with('Please enter desired email: ')
        allow(described_class).to receive(:gets) { "test\n" }
        described_class.prompt_for_git_email('')
      end
    end
  end

  describe '.fetch_git_global_name' do
    context 'with successful call to git and confirmation' do
      it 'returns the value from git' do
        allow_message_expectations_on_nil
        exec = 'git config --global user.name'
        result = 'Detected "A Name", is this correct? (y/n)'
        expect(described_class).to receive(:`).with(exec).and_return('A Name')
        allow($CHILD_STATUS).to receive(:success?).and_return(true)
        expect(STDOUT).to receive(:puts).with(result)
        allow(described_class).to receive(:gets) { "y\n" }
        expect(described_class.fetch_git_global_name).to eql('A Name')
      end
    end

    context 'with successful call to git and negation' do
      it 'returns the value entered' do
        allow_message_expectations_on_nil
        exec = 'git config --global user.name'
        e_r = 'Bad Name'
        results = 'Detected "Bad Name", is this correct? (y/n)'
        expect(described_class).to receive(:`).with(exec).and_return(e_r)
        allow($CHILD_STATUS).to receive(:success?).and_return(true)
        expect(STDOUT).to receive(:puts).with(results)
        allow(described_class).to receive(:gets) { "n\n" }
        expect(STDOUT).to receive(:puts).with('Please enter desired name: ')
        allow(described_class).to receive(:gets) { "New name\n" }
        expect(described_class.fetch_git_global_name).to eql('New name')
      end
    end

    context 'with a failure call to git' do
      it 'returns the value entered' do
        allow_message_expectations_on_nil
        exec = 'git config --global user.name'
        e_r = 'Fail Name'
        output = 'Could not detect name from git configuration.'
        results = 'A Name After Failure'
        expect(described_class).to receive(:`).with(exec).and_return(e_r)
        allow($CHILD_STATUS).to receive(:success?).and_return(false)
        expect(STDOUT).to receive(:puts).with(output)
        expect(STDOUT).to receive(:puts).with('Please enter desired name: ')
        allow(described_class).to receive(:gets) { "A Name After Failure\n" }
        expect(described_class.fetch_git_global_name).to eql(results)
      end
    end
  end

  describe '.fetch_git_global_email' do
    context 'with successful call to git and confirmation' do
      it 'returns the value from git' do
        allow_message_expectations_on_nil
        exec = 'git config --global user.email'
        e_r = 'my@email.com'
        output = 'Detected "my@email.com", is this correct? (y/n)'
        expect(described_class).to receive(:`).with(exec).and_return(e_r)
        allow($CHILD_STATUS).to receive(:success?).and_return(true)
        expect(STDOUT).to receive(:puts).with(output)
        allow(described_class).to receive(:gets) { "y\n" }
        expect(described_class.fetch_git_global_email).to eql('my@email.com')
      end
    end

    context 'with successful call to git and negation' do
      it 'returns the value entered' do
        allow_message_expectations_on_nil
        exec = 'git config --global user.email'
        e_r = 'bad@email.com'
        output = 'Detected "bad@email.com", is this correct? (y/n)'
        expect(described_class).to receive(:`).with(exec).and_return(e_r)
        allow($CHILD_STATUS).to receive(:success?).and_return(true)
        expect(STDOUT).to receive(:puts).with(output)
        allow(described_class).to receive(:gets) { "n\n" }
        expect(STDOUT).to receive(:puts).with('Please enter desired email: ')
        allow(described_class).to receive(:gets) { "new@email.com\n" }
        expect(described_class.fetch_git_global_email).to eql('new@email.com')
      end
    end

    context 'with a failure call to git' do
      it 'returns the value entered' do
        allow_message_expectations_on_nil
        exec = 'git config --global user.email'
        e_r = 'fail@email.com'
        output = 'Could not detect email from git configuration.'
        results = 'good@email.com'
        expect(described_class).to receive(:`).with(exec).and_return(e_r)
        allow($CHILD_STATUS).to receive(:success?).and_return(false)
        expect(STDOUT).to receive(:puts).with(output)
        expect(STDOUT).to receive(:puts).with('Please enter desired email: ')
        allow(described_class).to receive(:gets) { "good@email.com\n" }
        expect(described_class.fetch_git_global_email).to eql(results)
      end
    end
  end

  describe '.fetch_pkgdir' do
    it 'prompts the user for the directory' do
      output = 'Where should projects be checked out?'
      expect(STDOUT).to receive(:puts).with(output)
      allow(described_class).to receive(:gets) { "test\n" }
      described_class.fetch_pkgdir
    end

    it 'returns the value entered' do
      expect(STDOUT).to receive(:puts)
      allow(described_class).to receive(:gets) { '/tmp/packages' }
      expect(described_class.fetch_pkgdir).to eql('/tmp/packages')
    end

    it 'expands the given path' do
      path = File.expand_path('~/packages')
      expect(STDOUT).to receive(:puts)
      allow(described_class).to receive(:gets) { '~/packages' }
      expect(described_class.fetch_pkgdir).to eql(path)
    end
  end

  describe '.configure' do
    context 'with normal behavior' do
      it 'responds to configure' do
        expect(described_class).to respond_to(:configure)
      end
    end

    context 'with existing configuration' do
      it 'returns a hash' do
        allow(File).to receive(:file?).and_return(true)
        allow(YAML).to receive(:load_file).and_return(
          name: 'Mario Finelli',
          email: 'mario@example.com',
          pkgdir: '/tmp/packages')

        expect(described_class.configure).to be_a(Hash)
      end

      it 'returns the correct configuration' do
        allow(File).to receive(:file?).and_return(true)
        allow(YAML).to receive(:load_file).and_return(
          name: 'Mario Finelli',
          email: 'mario@example.com',
          pkgdir: '/tmp/packages')

        expect(described_class.configure).to eql(
          name: 'Mario Finelli',
          email: 'mario@example.com',
          pkgdir: '/tmp/packages')
      end
    end

    context 'with no existing configuration' do
      it 'asks the user name' do
        allow(File).to receive(:file?).and_return(false)
        allow(described_class).to receive(:fetch_git_global_email)
        allow(described_class).to receive(:fetch_pkgdir)
        expect(described_class).to receive(:fetch_git_global_name)
        described_class.configure
      end

      it 'asks the user email' do
        allow(File).to receive(:file?).and_return(false)
        allow(described_class).to receive(:fetch_git_global_name)
        allow(described_class).to receive(:fetch_pkgdir)
        expect(described_class).to receive(:fetch_git_global_email)
        described_class.configure
      end

      it 'asks the user where to store directories' do
        allow(File).to receive(:file?).and_return(false)
        allow(described_class).to receive(:fetch_git_global_name)
        allow(described_class).to receive(:fetch_git_global_email)
        expect(described_class).to receive(:fetch_pkgdir)
        described_class.configure
      end

      it 'writes a new configuration file' do
        path = '/tmp/aur-packages'
        allow(File).to receive(:file?).and_return(false)
        allow(described_class).to receive(:fetch_git_global_name)
          .and_return('Mario Finelli')
        allow(described_class).to receive(:fetch_git_global_email)
          .and_return('mario@example.com')
        allow(described_class).to receive(:fetch_pkgdir).and_return(path)
        allow(YAML).to receive(:load_file)
        expect(File).to receive(:write).with(
          described_class.conf_file,
          File.read(File.join(File.dirname(__FILE__),
                              'fixtures',
                              'configuration.yml')))
        described_class.configure
      end

      it 'returns the correct configuration' do
        path = '/tmp/aur-packages'
        allow(File).to receive(:file?).and_return(false)
        allow(described_class).to receive(:fetch_git_global_name)
          .and_return('Mario Finelli')
        allow(described_class).to receive(:fetch_git_global_email)
          .and_return('mario@example.com')
        allow(described_class).to receive(:fetch_pkgdir).and_return(path)
        allow(File).to receive(:write)
        allow(YAML).to receive(:load_file).and_return(
          YAML.load_file(File.join(File.dirname(__FILE__),
                                   'fixtures',
                                   'configuration.yml')))
        expect(described_class.configure).to eql(
          YAML.load_file(File.join(File.dirname(__FILE__),
                                   'fixtures',
                                   'configuration.yml')))
      end
    end
  end
end
