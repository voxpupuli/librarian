module Librarian
  class Manifest

    class Version
      include Comparable

      @@SEMANTIC_VERSION_PATTERN = /^([0-9]+\.[0-9]+(?:\.[0-9]+)?)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/

      attr_reader :prerelease

      def initialize(*args)
        args = initialize_normalize_args(args)
        semver = Version.parse_semver(*args)
        if semver
          self.backing  = Gem::Version.new(semver[:version])
          @prerelease   = semver[:prerelease]
          @full_version = semver[:full_version]
        else
          self.backing  = Gem::Version.new(*args)
          @full_version = to_gem_version.to_s
        end
      end

      def to_gem_version
        backing
      end

      def <=>(other)
        cmp = to_gem_version <=> other.to_gem_version

        # Should compare pre-release versions?
        if cmp == 0 and not (prerelease.nil? and other.prerelease.nil?)
          case # Versions without prerelease take precedence
            when (prerelease.nil? and not other.prerelease.nil?)
              1
            when (not prerelease.nil? and other.prerelease.nil?)
              -1
            else
              prerelease <=> other.prerelease
          end
        else
          cmp
        end
      end

      def to_s
        @full_version
      end

      def inspect
        "#<#{self.class} #{to_s}>"
      end

      def self.parse_semver(version_string)
        parsed = @@SEMANTIC_VERSION_PATTERN.match(version_string.strip)
        if parsed
          {
            :full_version => parsed[0],
            :version => parsed[1],
            :prerelease => (PreReleaseVersion.new(parsed[2]) if parsed[2]),
            :build => parsed[3]
          }
        end
      end

      private

      def initialize_normalize_args(args)
        args.map do |arg|
          arg = [arg] if self.class === arg
          arg
        end
      end

      attr_accessor :backing
    end
  end
end
