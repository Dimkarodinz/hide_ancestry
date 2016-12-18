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
        instance.hided_parent ? instance.hided_parent : instance.parent
      end

      def change_hided_status(boolean)
        instance.update_attribute instance.hided_column, boolean
      end
    end
  end
end