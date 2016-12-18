module HideAncestry
  module ModelManage
    class Hide < Base
      def call
        instance.reload
        change_hided_status(true)
        save_parent_id

        save_child_ids
        orphan_children
        clean_ancestry
      end

      private

      def save_parent_id
        actual_parent = find_actual_parent(instance)
        instance.update_attribute :old_parent_id, actual_parent&.id
      end

      def save_child_ids
        actual_children = []
        collections     = [:children, :hided_children]

        collections.each { |coll| save_sub_ids(coll, actual_children) }

        instance.update_attribute :old_child_ids, actual_children
      end

      def orphan_children
        instance.children.each do |child|
          child.update_attribute :parent_id, instance.find_first_real_parent&.id
        end
      end

      def clean_ancestry
        instance.update_attribute :ancestry, nil
      end

      def save_sub_ids(collection_name, array_to_save)
        instance.public_send(collection_name).each do |sub_node|
          array_to_save << sub_node.id
        end
      end
    end
  end
end