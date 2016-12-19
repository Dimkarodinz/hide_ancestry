module HideAncestry
  module InstanceMethods
    def hide
      return not_valid unless valid?
      HideAncestry::ModelManage::Hide.call(self)
    end

    def restore
      return not_valid unless valid?
      return already_restored unless public_send(hidden_column) == true
      HideAncestry::ModelManage::Restore.call(self)
    end

    def first_hiding?
      old_parent_changes = previous_changes['old_parent_id']
      return unless old_parent_changes
      old_parent_changes.first.nil?
    end

    def hidden?
      self.public_send(hidden_column) == true
    end

    def hide_ancestry_ids
      hide_ancestry.split('/').map(&:to_i) if hide_ancestry
    end

    def children_of_hidden
      self.class.where id: old_child_ids
    end

    def hidden_children
      self.class.hidden.where old_parent_id: id
    end

    def hidden_parent_changed?
      sought_parent = hidden_parent
      return false unless sought_parent

      # Existing parent (for hidden node and child of hidden) should be the same;
      # if not - means than child changed it parent
      grandparent = sought_parent.find_first_real_parent
      grandparent&.id != parent_id
    end

    def subtree_with_hidden
      sub_ids = subtree.pluck(:id)
      ids_for_search = sub_ids + hidden_descendants_ids
      relation = self.class.where id: ids_for_search
      relation.order(hide_ancestry: :asc)
    end

    def depth_with_hidden
      hide_ancestry_ids.size
    end

    def hidden_parent
      sought_parent =
        self.class.hidden.select do |u|
          u.old_child_ids.include? id
        end
      sought_parent.blank? ? nil : sought_parent.first
    end

    def hidden_children_present?
      self.class.hidden_childs(id).present?
    end

    def hidden_descendants_ids
      ids = []
      iterate_desc_for_hidden(ids)
      iterate_hidden_desc(ids)
      ids.uniq
    end

    def hidden_ids
      self.class.hidden.pluck(:id)
    end

    def find_first_real_parent
      parent_usr = self.class.find_by id: old_parent_id
      return parent unless parent_usr
      parent_usr.hidden? ? parent_usr.find_first_real_parent : parent_usr
    end

    # Monkeypatching ActiveModel::Dirty method
    # to correct work of #previous_changes in model
    def changes_applied
      @previously_changed = @record_changes
      @changed_attributes = ActiveSupport::HashWithIndifferentAccess.new
    end

    protected

    def iterate_desc_for_hidden(array)
      descendants.each do |user|
        user.hidden_children.each { |child| array << child.id }
      end
    end

    def iterate_hidden_desc(array)
      hidden_children.each do |hidden_child|
        array << hidden_child.id
        hidden_child.iterate_hidden_desc(array)
      end
    end
  end
end