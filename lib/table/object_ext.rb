module Table
  module ObjectExt
    private

    # Shortcut for Table::Definition.new
    def Table(&definition) = Table::Definition.new(&definition)
  end
end

Object.send(:include, Table::ObjectExt)
