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
        allow(Gembuild).to receive(:gets) { 'Yes' }
        Gembuild.prompt_for_confirmation('test')
      end

      it 'should return a boolean' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { 'Yes' }
        expect(Gembuild.prompt_for_confirmation('test')).to be_truthy
      end
    end

    context 'with negative uppercase response' do
      it 'should return false' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { 'No' }
        expect(Gembuild.prompt_for_confirmation('test')).to eql(false)
      end
    end

    context 'with negative lowercase response' do
      it 'should return false' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { 'n' }
        expect(Gembuild.prompt_for_confirmation('test')).to eql(false)
      end
    end

    context 'with affermative uppercase response' do
      it 'should return true' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { 'Y' }
        expect(Gembuild.prompt_for_confirmation('test')).to eql(true)
      end
    end

    context 'with affermative lowercase response' do
      it 'should return true' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { 'yes' }
        expect(Gembuild.prompt_for_confirmation('test')).to eql(true)
      end
    end

    context 'with invalid response' do
      it 'should return false' do
        allow(STDOUT).to receive(:puts)
        allow(Gembuild).to receive(:gets) { 'AAA' }
        expect(Gembuild.prompt_for_confirmation('test')).to eql(false)
      end
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
  end
end
