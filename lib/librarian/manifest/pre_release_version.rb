module Librarian
  class Manifest

    class PreReleaseVersion

      # Compares pre-release component ids using Semver 2.0.0 spec
      def self.compare_components(this_id,other_id)
        case # Strings have higher precedence than numbers
          when (this_id.is_a?(Integer) and other_id.is_a?(String))
            -1
          when (this_id.is_a?(String) and other_id.is_a?(Integer))
            1
          else
            this_id <=> other_id
        end
      end

      # Parses pre-release components `a.b.c` into an array ``[a,b,c]`
      # Converts numeric components into +Integer+
      def self.parse(prerelease)
        if prerelease.nil?
          []
        else
          prerelease.split('.').collect do |id|
            id = Integer(id) if /^[0-9]+$/ =~ id
            id
          end
        end
      end

      include Comparable

      attr_reader :components

      def initialize(prerelease)
        @prerelease = prerelease
        @components = PreReleaseVersion.parse(prerelease)
      end

      def to_s
        @prerelease
      end

      def <=>(other)
        # null-fill zip array to prevent loss of components
        z = Array.new([components.length,other.components.length])

        # Compare each component against the other
        comp = z.zip(components,other.components).collect do |ids|
          case # All components being equal, the version with more of them takes precedence
            when ids[1].nil? # Self has less elements, other wins
              -1
            when ids[2].nil? # Other has less elements, self wins
              1
            else
              PreReleaseVersion.compare_components(ids[1],ids[2])
          end
        end
        # Chose the first non-zero comparison or return 0
        comp.delete_if {|c| c == 0}[0] || 0
      end
    end
  end
end
