module HideAncestry
  module ModelManage
    class CustomAncestryUpdater < Base
      def call
        # if descendant of hided node will change its parent
        clean_instance_from_hided_parent if instance.hided_parent_changed?
        change_hide_ancestry_cols(instance) unless instance.hided?

        # first, general iteration; useful when node updated
        instance.children.each { |child| update_each_child(child, instance) }

        # fix nodes with #hided? and its descendant nodes
        instance.hided_children.each do |hided_children|
          update_hided_with_descendants(hided_children, instance)
        end
      end

      private

      def change_hide_ancestry_cols(instance, custom_parent = nil)
        custom_parent = instance.hided_parent unless custom_parent
        set_depth_level(instance, custom_parent)
        set_hide_ancestry(instance, custom_parent)
      end

      # remove node_1#id from node_2#old_child_ids;
      # node_2 should be hided
      def clean_instance_from_hided_parent
        return if instance.hided?

        new_array =
          instance.hided_parent&.old_child_ids.reject { |el| el == instance.id }
        instance.hided_parent
            .update_attribute(:old_child_ids, new_array)
      end

      def update_each_child(instance, parent)
        change_hide_ancestry_cols(instance, parent)
        update_hided_children_cols(instance) if instance.hided_children_present?

        instance.children.each { |child| update_each_child(child, instance) }
      end

      # udpate alternate ancestry cols of node#hided? and its descendant
      def update_hided_with_descendants(instance, parent)
        change_hide_ancestry_cols(instance, parent)

        if instance.hided?
          instance.children_of_hided.each do |child|
            update_hided_with_descendants(child, instance)
          end
        else
          instance.children.each do |child|
            update_hided_children_cols(child) if instance.hided_children_present?
            update_hided_with_descendants(child, instance)
          end      
        end
      end

      def update_hided_children_cols(instance)
        instance.hided_children.each do |hided_child|
          change_hide_ancestry_cols(hided_child, instance)
        end
      end

      # TODO: if options[:depth_level]
      def set_depth_level instance, custom_parent = nil
        instance.update_column(
          :depth_level,
          readable_depth_level(instance, custom_parent)
          )
        instance.reload
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
          ids = custom_parent.hide_ancestry_path_ids << instance.id
          ids.join('/')

        # If hide_ancestry blank
        else
          instance.parent_id.blank? ? instance.id.to_s : instance.path_ids.join('/')
        end
      end

      # for making strings like '1.2.3'
      def readable_depth_level instance, custom_parent = nil
        iterations =
          custom_parent ? depth_level_depth(custom_parent) + 1 : instance.depth
        counter, levels  = 0, []

        iterations.times do
          counter += 1
          levels << counter
        end

        counter.zero? ? '0' : levels.join('.')
      end

      def depth_level_depth(instance)
        return unless instance.depth_level
        return 0 if instance.depth_level.to_i.zero?
        instance.depth_level.delete('.').size
      end
    end
  end
end