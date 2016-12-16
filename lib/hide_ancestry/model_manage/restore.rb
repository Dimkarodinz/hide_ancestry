module HideAncestry
  module ModelManage
    class Restore < Base
      def call
        instance.reload
        restore_parent
        restore_children
        change_hided_status(false)
      end

      private

      def restore_parent
        unless instance.parent_id
          instance.update_attribute :parent_id, instance.find_first_real_parent&.id
        end
      end

      def restore_children
        instance.old_child_ids.each do |child_id|
          child = instance.class.find_by id: child_id

          next unless child
          next if child.hided?

          child.update_attribute :parent_id, instance.id
        end
      end 
    end
  end
end