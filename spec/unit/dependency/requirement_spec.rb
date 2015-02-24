require "librarian/dependency"

describe Librarian::Dependency::Requirement do

  describe "#inspect" do
    subject(:requirement) { described_class.new(">= 3.2.1") }

    specify { expect(requirement.inspect).
      to eq "#<Librarian::Dependency::Requirement >= 3.2.1>" }
  end

  it 'should handle .x versions' do
    described_class.new('1.x').to_gem_requirement.should eq(Gem::Requirement.new('~> 1.0'))
    described_class.new('1.0.x').to_gem_requirement.should eq(Gem::Requirement.new('~> 1.0.0'))
  end

  it 'should handle version ranges' do
    described_class.new('>=1.1.0 <2.0.0').to_gem_requirement.should eq(Gem::Requirement.new(['>=1.1.0', '<2.0.0']))
  end

  it 'should print to_s' do
    described_class.new('1.x').to_s.should eq('~> 1.0')
    s = described_class.new('>=1.1.0 <2.0.0').to_s
    s.should include(">= 1.1.0")
    s.should include("< 2.0.0")
  end

end
