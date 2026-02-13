class Table
  include Enumerable

  # Create a new table, defined within the given block.
  def initialize(&definition)
    definition or raise ArgumentError, "definition block required"

    @definition = definition
    @evaluation = definition.arity.zero? ? EvaluationContext : EvaluationArgument
    super()
  end

  # Evaluate the table definition and pass each generated element to the given block.
  #
  # Return the result of the definition block (NOT the given block).
  def call(&block)
    block or raise ArgumentError, "row handler block required"

    @evaluation.(@definition, &block)
  end

  # Given a block, evaluate the table definition and pass each generated element to the block,
  # then return +self+.
  #
  # With no block, return a new Enumerator for the table.
  def each(&block)
    if block.nil?
      to_enum
    else
      self.(&block)
      self
    end
  end

  SKIP = Object.new.freeze
  REPEAT = Object.new.freeze

  class Evaluation
    def self.call(definition, &block) = raise NoMethodError

    def initialize(&block)
      @block = block
      @values = {}
      super()
    end

    def skip = SKIP
    def _ = SKIP

    def repeat = REPEAT
    def `(s) = s.empty? ? REPEAT : super

    def extra(**extra)
      @extra = extra.to_h.freeze
    end

    def head(*keys)
      @keys = keys.freeze
      @values.clear
    end

    def data(*values)
      @keys or raise ArgumentError, "no columns have been defined"

      values.size == @keys.size or
        raise ArgumentError, "wrong number of columns (given #{values.size}, expected #{@keys.size})"

      row = @extra ? @extra.dup : {}

      values.each_with_index do |value, i|
        if value == REPEAT
          @values.key?(i) or raise ArgumentError, "no previous rows to repeat"
          row[@keys[i]] = @values[i]
        elsif value != SKIP
          @values[i] = value
          row[@keys[i]] = value
        end
      end

      @block.(row)
    end

    alias tx extra
    alias th head
    alias td data
  end

  class EvaluationContext < Evaluation
    def self.call(definition, &block) = new(&block).instance_eval(&definition)
  end

  class EvaluationArgument < Evaluation
    def self.call(definition, &block) = definition.(new(&block))

    alias x extra
    alias h head
    alias d data
  end

  module ObjectExt
    private
    def Table(&definition) = Table.new(&definition)
  end

  Object.send(:include, ObjectExt)
end
