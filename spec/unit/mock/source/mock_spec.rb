require "librarian/mock"

module Librarian
  module Mock
    module Source
      describe Mock do

        let(:env) { Librarian::Mock::Environment.new }

        describe ".new" do

          let(:source) { described_class.new(env, "source-a", {}) }
          subject { source }

          it { expect(subject.environment).to_not be_nil }

        end

      end
    end
  end
end
