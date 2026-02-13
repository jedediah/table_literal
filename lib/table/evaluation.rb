module Table
  # Token object returned by Table::Evalutation#ignore
  IGNORE = Object.new
  def IGNORE.inspect = "#{Table}::IGNORE"

  # Token object returned by Table::Evalutation#repeat
  REPEAT = Object.new
  def REPEAT.inspect = "#{Table}::REPEAT"

  # Instantiated for each evaluation of a table definition.
  # Implements the table DSL.
  class Evaluation
    # Evaluate the given table definition block, yielding rows to the given handler block.
    # Return the result of the definition block.
    #
    # This method is abstract and must be called on the appropriate subclass
    # for the given definition block.
    def self.call(definition, &handler) = raise NoMethodError

    # Evaluation of a table definiton that does not accept arguments
    class InContext < self
      def self.call(definition, &handler) = new(&handler).instance_exec(&definition)
    end

    # Evalutation of a table definition that can accept a single argument
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

    # Special value indicating that a table data cell should repeat the last value in the same column.
    # That column must contain an actual value since the last call to #head.
    # Ignored cells are not repeated.
    def repeat = REPEAT
    alias_method :”, :repeat

    # If argument is an empty string, this is an alias for #repeat.
    # Otherwise, this delegates to the default implementation (which is typically Kernel#`).
    def `(s) = s.empty? ? REPEAT : super

    # Define extra key/value pairs included in every output row.
    # Each call replaces any previously set extra data.
    # Any number of pairs can be given, including zero.
    def extra(**extra)
      @extra = extra.freeze
    end
    alias_method :tx, :extra

    # Define keys for the table columns.
    # Keys can be any object usable as a Hash key, but must be unique.
    # Each call replaces any previously defined columns.
    # Returns a frozen Array of the given keys.
    def head(*keys)
      keys_hash = {}
      keys.each do |key|
        keys_hash.key?(key) and raise ArgumentError, "duplicate column key #{key.inspect}"
        keys_hash[key] = nil
      end

      @values.clear
      @keys = keys.freeze
    end
    alias_method :th, :head

    # Define a row of data for the table, and yield the resulting Hash to the row handler.
    # Must be called after #head, and must have the same number of arguments as the last call to #head.
    # Has special behavior for the values returned from #ignore and #repeat.
    # Returns the result of the row handler.
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
