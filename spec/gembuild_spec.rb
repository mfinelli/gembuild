# encoding: utf-8

describe Gembuild do
  describe '#configure' do
    context 'with normal behavior' do
      it 'should respond to configure' do
        expect(Gembuild).to respond_to(:configure)
      end
    end

    context 'with existing configuration' do
      it 'shoudl return a hash' do
        File.stub(:file?).and_return(true)
        YAML.stub(:load_file).and_return({name: 'Mario Finelli', email: 'mario@example.com', pkgdir: '/tmp/packages'})

        expect(Gembuild.configure).to be_a(Hash)
      end

      it 'should return the correct configuration' do
        File.stub(:file?).and_return(true)
        YAML.stub(:load_file).and_return({name: 'Mario Finelli', email: 'mario@example.com', pkgdir: '/tmp/packages'})

        expect(Gembuild.configure).to eql({name: 'Mario Finelli', email: 'mario@example.com', pkgdir: '/tmp/packages'})
      end
    end
  end
end
