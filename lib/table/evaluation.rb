module Table
  # Table data cells with this value are ommitted from output
  IGNORE = Object.new
  def IGNORE.inspect = "#{Table}::IGNORE"

  # Table data cells with this value will repeat the last value in the same column
  REPEAT = Object.new
  def REPEAT.inspect = "#{Table}::REPEAT"

  # Instantiated for each evaluation of a table definition.
  # Implements the table DSL.
  class Evaluation
    def self.call(definition, &handler) = raise NoMethodError

    class InContext < self
      def self.call(definition, &handler) = new(&handler).instance_exec(&definition)
    end

    class WithArgument < self
      def self.call(definition, &handler) = definition.(new(&handler))
    end

    def initialize(&handler)
      @handler = handler
      @values = {}
      super()
    end

    # Special value indicating that a table data cell should be ignored.
    # If there is #extra data with the same key, that value will be used instead.
    # Otherwise, the key is ommitted from the output for this row.
    def ignore = IGNORE
    alias_method :_, :ignore

    # Table data cells with this value will repeat the last value in the same column
    def repeat = REPEAT
    alias_method :”, :repeat

    # If argument is an empty string, calls #repeat.
    # Otherwise, calls super (which is typically Kernel#`).
    def `(s) = s.empty? ? REPEAT : super

    # Define extra
    def extra(**extra)
      @extra = extra.freeze
    end
    alias_method :tx, :extra

    def head(*keys)
      keys_hash = {}
      keys.each do |key|
        keys_hash.key?(key) and raise ArgumentError, "duplicate column key #{key.inspect}"
        keys_hash[key] = nil
      end

      @keys = keys.freeze
      @values.clear
    end
    alias_method :th, :head

    def data(*values)
      @keys or raise ArgumentError, "no columns have been defined"

      values.size == @keys.size or
        raise ArgumentError, "wrong number of columns (given #{values.size}, expected #{@keys.size})"

      row = @extra ? @extra.dup : {}

      values.each_with_index do |value, i|
        if value == REPEAT
          @values.key?(i) or raise ArgumentError, "no previous rows to repeat"
          row[@keys[i]] = @values[i]
        elsif value != IGNORE
          @values[i] = value
          row[@keys[i]] = value
        end
      end

      @handler.(row)
    end
    alias_method :td, :data
  end
end
