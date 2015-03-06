require "librarian/environment"
require "librarian/ui"
require "librarian/mock/dsl"
require "librarian/mock/version"
require 'thor'

module Librarian
  module Mock
    class Environment < Environment

      def ui
        Librarian::UI::Shell.new(Thor::Shell::Basic.new)
      end

      def registry(options = nil, &block)
        @registry ||= Source::Mock::Registry.new
        @registry.merge!(options, &block)
        @registry
      end

    end
  end
end
