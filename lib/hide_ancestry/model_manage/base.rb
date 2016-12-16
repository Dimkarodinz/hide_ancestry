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
        instance.fired_parent ? instance.fired_parent : instance.parent
      end

      # TODO: if options[:custom_column]...
      def change_hided_status(boolean)
        instance.update_attribute :hided_status, boolean
      end
    end
  end
end