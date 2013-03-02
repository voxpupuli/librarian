require "securerandom"

require "support/cli_macro"

require "librarian/mock/cli"

module Librarian
  module Mock
    describe Cli do
      include CliMacro

      describe "version" do
        before do
          cli! "version"
        end

        it "should print the version" do
          stdout.should == strip_heredoc(<<-STDOUT)
            librarian-#{Librarian::VERSION}
            librarian-mock-#{Librarian::Mock::VERSION}
          STDOUT
        end
      end

    end
  end
end