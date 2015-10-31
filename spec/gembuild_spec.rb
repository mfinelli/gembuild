# encoding: utf-8

describe Gembuild do
  describe '#configure' do
    context 'with normal behavior' do
    it 'should respond to configure' do
      expect(Gembuild).to respond_to(:configure)
    end
  end
  end
end
