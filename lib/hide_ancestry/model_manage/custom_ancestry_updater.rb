module HideAncestry
  module ModelManage
    class CustomAncestryUpdater < Base
      def call
        # If descendant of hiden node will change its parent
        clean_instance_from_hiden_parent if instance.hiden_parent_changed?
        change_hide_ancestry_col(instance) unless instance.hiden?

        # First, general iteration; useful when node updated
        instance.children.each { |child| update_each_child(child, instance) }

        # Fix nodes with #hiden? and its descendant nodes
        instance.hiden_children.each do |hiden_children|
          update_hiden_with_descendants(hiden_children, instance)
        end
      end

      private

      def change_hide_ancestry_col(instance, custom_parent = nil)
        custom_parent = instance.hiden_parent unless custom_parent
        set_hide_ancestry(instance, custom_parent)
      end

      # Remove node_1#id from node_2#old_child_ids;
      # node_2 should be hiden
      def clean_instance_from_hiden_parent
        return if instance.hiden?

        new_array =
          instance.hiden_parent&.old_child_ids.reject { |el| el == instance.id }
        instance.hiden_parent
            .update_attribute(:old_child_ids, new_array)
      end

      def update_each_child(instance, parent)
        change_hide_ancestry_col(instance, parent)
        update_hiden_children_cols(instance) if instance.hiden_children_present?

        instance.children.each { |child| update_each_child(child, instance) }
      end

      # Udpate alternate ancestry cols of node#hiden? and its descendant
      def update_hiden_with_descendants(instance, parent)
        change_hide_ancestry_col(instance, parent)

        if instance.hiden?
          instance.children_of_hiden.each do |child|
            update_hiden_with_descendants(child, instance)
          end
        else
          instance.children.each do |child|
            update_hiden_children_cols(child) if instance.hiden_children_present?
            update_hiden_with_descendants(child, instance)
          end      
        end
      end

      def update_hiden_children_cols(instance)
        instance.hiden_children.each do |hiden_child|
          change_hide_ancestry_col(hiden_child, instance)
        end
      end

      def set_hide_ancestry instance, custom_parent = nil
        instance.update_column(
          :hide_ancestry,
          make_alternate_ancestry(instance, custom_parent)
          )
        instance.reload
      end

      # Makes alternate #ancestry, including node#id
      def make_alternate_ancestry instance, custom_parent = nil
        if custom_parent
          ids = custom_parent.hide_ancestry_ids << instance.id
          ids.join('/')

        # If hide_ancestry blank
        else
          instance.parent_id.blank? ? instance.id.to_s : instance.path_ids.join('/')
        end
      end
    end
  end
end