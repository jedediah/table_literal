require 'factory_bot'

module Table
  module FactoryBotExt
    module StrategySyntaxMethodRegistrar
      # Define the *_table method for this strategy
      def define_table_strategy_method
        strategy_name = @strategy_name

        define_syntax_method("#{strategy_name}_table") do |name, *traits, &table|
          results = []

          Table::Definition.new(&table).each do |overrides|
            result = send(strategy_name, name, *traits, **overrides)
            results << result
            result # Return the product from the row definition
          end

          results
        end
      end
    end
  end
end

module FactoryBot
  class StrategySyntaxMethodRegistrar
    include Table::FactoryBotExt::StrategySyntaxMethodRegistrar

    # Monkey-patch define_strategy_methods to additionally call define_table_strategy_method.
    # This will take care of strategies registered _after_ loading this extension.
    def define_strategy_methods__with_table
      define_strategy_methods__without_table
      define_table_strategy_method
    end

    alias_method :define_strategy_methods__without_table, :define_strategy_methods
    alias_method :define_strategy_methods, :define_strategy_methods__with_table
  end

  # Detect strategies registered _before_ this extension was loaded,
  # and call define_table_strategy_method for each them.
  #
  # There is no way to enumerate keys in a FactoryBot::Registry, so scan all syntax methods
  # and check if each one is registered as a strategy.
  Syntax::Methods.instance_methods.each do |strategy|
    Internal.strategies.registered?(strategy) and
      StrategySyntaxMethodRegistrar.new(strategy).define_table_strategy_method
  end
end
