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
        instance.hiden_parent ? instance.hiden_parent : instance.parent
      end

      def change_hiden_status(boolean)
        instance.update_attribute instance.hiden_column, boolean
      end
    end
  end
end