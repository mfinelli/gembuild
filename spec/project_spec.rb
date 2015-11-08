# encoding: utf-8

describe Gembuild::Project do
  describe '#initialize' do
    it 'should return a project' do
      expect(Gembuild::Project.new('mina')).to be_a(Gembuild::Project)
    end
  end
end
