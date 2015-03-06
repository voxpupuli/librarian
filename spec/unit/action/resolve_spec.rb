require "librarian/error"
require "librarian/logger"
require "librarian/action/resolve"
require "librarian/mock/environment"
require "librarian/mock/source"

module Librarian
  describe Action::Resolve do

    let(:options) { {} }
    let(:spec) { Spec.new([], dependencies, []) }
    let(:env) { Librarian::Mock::Environment.new }
    let(:action) { described_class.new(env, options) }
    let(:source1) { Librarian::Mock::Source::Mock.new(env, "source1", {}) }
    let(:source2) { Librarian::Mock::Source::Mock.new(env, "source2", {}) }

    before do
      env.stub(:specfile => double(:read => spec))
    end

    describe "#run" do

      describe "behavior" do

        describe "merge duplicated dependencies" do
          let(:options) { {:force => true} }
          let(:dependency1) { Dependency.new('dependency_name', '1.0.0', source1) }
          let(:dependency2) { Dependency.new('dependency_name', '1.0.0', source2) }
          let(:dependencies) { [ dependency1, dependency2 ] }
          let(:manifest) do
            m = Manifest.new(source1, dependency1.name)
            m.version = '1.0.0'
            m.dependencies = []
            m
          end

          it "should merge duplicated dependencies" do
            Dependency.any_instance.stub(:manifests => [manifest])
            action.stub(:persist_resolution)
            resolution = action.run
            expect(resolution.dependencies).to eq([dependency2])
          end

        end

      end

    end

  end
end
