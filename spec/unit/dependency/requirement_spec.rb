require "librarian/dependency"

describe Librarian::Dependency::Requirement do

  describe "#inspect" do
    subject(:requirement) { described_class.new(">= 3.2.1") }

    specify { expect(requirement.inspect).
      to eq "#<Librarian::Dependency::Requirement >= 3.2.1>" }
  end

  it 'should handle nil versions' do
    expect(described_class.new(nil).to_gem_requirement).to eq(Gem::Requirement.new)
  end

  it 'should handle nil versions in arrays' do
    expect(described_class.new([nil]).to_gem_requirement).to eq(Gem::Requirement.new)
  end

  it 'should handle .x versions' do
    expect(described_class.new('1.x').to_gem_requirement).to eq(Gem::Requirement.new('~> 1.0'))
    expect(described_class.new('1.0.x').to_gem_requirement).to eq(Gem::Requirement.new('~> 1.0.0'))
  end

  it 'should handle version ranges' do
    expect(described_class.new('>=1.1.0 <2.0.0').to_gem_requirement).to eq(Gem::Requirement.new(['>=1.1.0', '<2.0.0']))
    expect(described_class.new('>=1.1.0  <2.0.0').to_gem_requirement).to eq(Gem::Requirement.new(['>=1.1.0', '<2.0.0']))
  end

  it 'should print to_s' do
    expect(described_class.new('1.x').to_s).to eq('~> 1.0')
    s = described_class.new('>=1.1.0 <2.0.0').to_s
    expect(s).to include(">= 1.1.0")
    expect(s).to include("< 2.0.0")
  end

end
