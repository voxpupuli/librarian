require "librarian/error"
require "librarian/action/resolve"
require "librarian/mock/source"

module Librarian
  describe Action::Resolve do

    let(:options) { {} }
    let(:spec) { double() }
    let(:env) { double(:specfile => double(:read => spec)) }
    let(:action) { described_class.new(env, options) }

    describe "#run" do

      describe "behavior" do

        describe "fail with duplicated dependencies" do
          let(:options) { {:force => true} }
          let(:dependency) { Dependency.new('dependency_name', '1.0.0', nil ) }
          let(:dependencies) { [ dependency, dependency ] }
          let(:spec) { double(:dependencies => dependencies) }

          it "should fail with duplicated dependencies" do
            expect { action.run }.to raise_error(Error, /^Duplicated dependencies: /)
          end

        end

      end

    end

  end
end
