module HideAncestry
  module ModelManage
    class Base
      def self.call(instance)
        new(instance).call
      end

      attr_accessor :instance

      def initialize(instance)
        @instance = instance
      end

      private

      def find_actual_parent(instance)
        instance.hidden_parent ? instance.hidden_parent : instance.parent
      end

      def change_hidden_status(boolean)
        instance.update_attribute instance.hidden_column, boolean
      end
    end
  end
end