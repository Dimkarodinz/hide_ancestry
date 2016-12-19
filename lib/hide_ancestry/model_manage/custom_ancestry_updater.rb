module HideAncestry
  module ModelManage
    class CustomAncestryUpdater < Base
      def call
        # If descendant of hidden node will change its parent
        clean_instance_from_hidden_parent if instance.hidden_parent_changed?
        change_hide_ancestry_col(instance) unless instance.hidden?

        # First, general iteration; useful when node updated
        instance.children.each { |child| update_each_child(child, instance) }

        # Fix nodes with #hidden? and its descendant nodes
        instance.hidden_children.each do |hidden_children|
          update_hidden_with_descendants(hidden_children, instance)
        end
      end

      private

      def change_hide_ancestry_col(instance, custom_parent = nil)
        custom_parent = instance.hidden_parent unless custom_parent
        set_hide_ancestry(instance, custom_parent)
      end

      # Remove node_1#id from node_2#old_child_ids;
      # node_2 should be hidden
      def clean_instance_from_hidden_parent
        return if instance.hidden?

        new_array =
          instance.hidden_parent&.old_child_ids.reject { |el| el == instance.id }
        instance.hidden_parent
            .update_attribute(:old_child_ids, new_array)
      end

      def update_each_child(instance, parent)
        change_hide_ancestry_col(instance, parent)
        update_hidden_children_cols(instance) if instance.hidden_children_present?

        instance.children.each { |child| update_each_child(child, instance) }
      end

      # Udpate alternate ancestry cols of node#hidden? and its descendant
      def update_hidden_with_descendants(instance, parent)
        change_hide_ancestry_col(instance, parent)

        if instance.hidden?
          instance.children_of_hidden.each do |child|
            update_hidden_with_descendants(child, instance)
          end
        else
          instance.children.each do |child|
            update_hidden_children_cols(child) if instance.hidden_children_present?
            update_hidden_with_descendants(child, instance)
          end      
        end
      end

      def update_hidden_children_cols(instance)
        instance.hidden_children.each do |hidden_child|
          change_hide_ancestry_col(hidden_child, instance)
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