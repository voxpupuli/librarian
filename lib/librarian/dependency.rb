require 'rubygems'

module Librarian
  class Dependency

    class Requirement
      def initialize(*args)
        args = initialize_normalize_args(args)

        self.backing = Gem::Requirement.create(args)
      end

      def to_gem_requirement
        backing
      end

      def satisfied_by?(version)
        to_gem_requirement.satisfied_by?(version.to_gem_version)
      end

      def ==(other)
        to_gem_requirement == other.to_gem_requirement
      end

      alias :eql? :==

      def hash
        self.to_s.hash
      end

      def to_s
        to_gem_requirement.to_s
      end

      def inspect
        "#<#{self.class} #{to_s}>"
      end

      COMPATS_TABLE = {
        %w(=  = ) => lambda{|s, o| s == o},
        %w(=  !=) => lambda{|s, o| s != o},
        %w(=  > ) => lambda{|s, o| s >  o},
        %w(=  < ) => lambda{|s, o| s <  o},
        %w(=  >=) => lambda{|s, o| s >= o},
        %w(=  <=) => lambda{|s, o| s <= o},
        %w(=  ~>) => lambda{|s, o| s >= o && s.release < o.bump},
        %w(!= !=) => true,
        %w(!= > ) => true,
        %w(!= < ) => true,
        %w(!= >=) => true,
        %w(!= <=) => true,
        %w(!= ~>) => true,
        %w(>  > ) => true,
        %w(>  < ) => lambda{|s, o| s < o},
        %w(>  >=) => true,
        %w(>  <=) => lambda{|s, o| s < o},
        %w(>  ~>) => lambda{|s, o| s < o.bump},
        %w(<  < ) => true,
        %w(<  >=) => lambda{|s, o| s > o},
        %w(<  <=) => true,
        %w(<  ~>) => lambda{|s, o| s > o},
        %w(>= >=) => true,
        %w(>= <=) => lambda{|s, o| s <= o},
        %w(>= ~>) => lambda{|s, o| s < o.bump},
        %w(<= <=) => true,
        %w(<= ~>) => lambda{|s, o| s >= o},
        %w(~> ~>) => lambda{|s, o| s < o.bump && s.bump > o},
      }

      def consistent_with?(other)
        sgreq, ogreq = to_gem_requirement, other.to_gem_requirement
        sreqs, oreqs = sgreq.requirements, ogreq.requirements
        sreqs.all? do |sreq|
          oreqs.all? do |oreq|
            compatible?(sreq, oreq)
          end
        end
      end

      def inconsistent_with?(other)
        !consistent_with?(other)
      end

      protected

      attr_accessor :backing

      private

      def initialize_normalize_args(args)
        args.map do |arg|
          arg = arg.backing if self.class === arg
          case arg
          when nil
            nil
          when Array
            arg.map { |item| parse(item) }
          when String
            parse(arg)
          else
            # Gem::Requirement, convert to string (ie. =1.0) so we can concat later
            # Gem::Requirements can not be concatenated
            arg.requirements.map{|x,y| "#{x}#{y}"}
          end
        end.flatten
      end

      # build an array if the argument is a string defining a range
      # or a ~> 1.0 type version if string is 1.x
      def parse(arg)
        match = range_requirement(arg)
        return [match[1], match[2]] if match
        match = pessimistic_requirement(arg)
        return "~> #{match[1]}.0" if match
        arg
      end

      def compatible?(a, b)
        a, b = b, a unless COMPATS_TABLE.include?([a.first, b.first])
        r = COMPATS_TABLE[[a.first, b.first]]
        r = r.call(a.last, b.last) if r.respond_to?(:call)
        r
      end

      # A version range: >=1.0 <2.0
      def range_requirement(arg)
        arg.match(/(>=? ?\d+(?:\.\d+){0,2}) (<=? ?\d+(?:\.\d+){0,2})/)
      end

      # A string with .x: 1.x, 2.1.x
      def pessimistic_requirement(arg)
        arg.match(/(\d+(?:\.\d+)?)\.x/)
      end
    end

    attr_accessor :name, :requirement, :source
    private :name=, :requirement=, :source=

    def initialize(name, requirement, source)
      assert_name_valid! name

      self.name = name
      self.requirement = Requirement.new(requirement)
      self.source = source

      @manifests = nil
    end

    def manifests
      @manifests ||= cache_manifests!
    end

    def cache_manifests!
      source.manifests(name)
    end

    def satisfied_by?(manifest)
      manifest.satisfies?(self)
    end

    def to_s
      "#{name} (#{requirement}) <#{source}>"
    end

    def ==(other)
      !other.nil? &&
      self.class        == other.class        &&
      self.name         == other.name         &&
      self.requirement  == other.requirement  &&
      self.source       == other.source
    end

    def consistent_with?(other)
      name != other.name || requirement.consistent_with?(other.requirement)
    end

    def inconsistent_with?(other)
      !consistent_with?(other)
    end

  private

    def assert_name_valid!(name)
      name =~ /\A\S(?:.*\S)?\z/ and return

      raise ArgumentError, "name (#{name.inspect}) must be sensible"
    end

  end
end
