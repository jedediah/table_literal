module Table
  class Definition
    include Enumerable

    # Create a new table, defined within the given block.
    def initialize(&definition)
      definition or raise ArgumentError, "definition block required"

      @definition = definition
      @evaluator = definition.arity.zero? ? Evaluation::InContext : Evaluation::WithArgument
      super()
    end

    # The table definition block that was passed to +new+
    def to_proc = @definition

    # Evaluate the table definition and pass each generated element to the given block.
    #
    # Return the result of the definition block (NOT the given block).
    def call(&block)
      block or raise ArgumentError, "row handler block required"

      @evaluator.(@definition, &block)
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
  end
end
