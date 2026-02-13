module Table
  SKIP = Object.new
  def SKIP.inspect = "#{Table}::SKIP"

  REPEAT = Object.new
  def REPEAT.inspect = "#{Table}::REPEAT"

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
    def ” = REPEAT
    def `(s) = s.empty? ? REPEAT : super

    def extra(**extra)
      @extra = extra.freeze
    end

    def head(*keys)
      keys_hash = {}
      keys.each do |key|
        keys_hash.key?(key) and raise ArgumentError, "duplicate column key #{key.inspect}"
        keys_hash[key] = nil
      end

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

    alias_method :tx, :extra
    alias_method :th, :head
    alias_method :td, :data
  end

  class EvaluationInContext < Evaluation
    def self.call(definition, &block) = new(&block).instance_exec(&definition)
  end

  class EvaluationWithArgument < Evaluation
    def self.call(definition, &block) = definition.(new(&block))
  end
end
