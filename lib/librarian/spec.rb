module Librarian
  class Spec

    attr_accessor :sources, :dependencies, :exclusions
    private :sources=, :dependencies=, :exclusions=

    def initialize(sources, dependencies, exclusions = [])
      self.sources = sources
      self.dependencies = dependencies
      self.exclusions = exclusions
    end

  end
end
