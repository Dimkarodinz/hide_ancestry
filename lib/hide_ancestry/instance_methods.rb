module HideAncestry
  module InstanceMethods
    def hide
      return not_valid_error unless valid?
      HideAncestry::ModelManage::Hide.call(self)
    end

    def restore
      return not_valid_error unless valid?
      return already_restored_error unless hided_status == true
      HideAncestry::ModelManage::Restore.call(self)
    end

    def first_hiding?
      old_parent_changes = previous_changes['old_parent_id']
      return unless old_parent_changes
      old_parent_changes.first.nil?
    end

    # if options[:custom_column]...
    def hided?
      hided_status == true
    end

    def hide_ancestry_path_ids
      self.hide_ancestry.split('/').map(&:to_i)
    end

    def children_of_hided
      self.class.where id: old_child_ids
    end

    def hided_children
      self.class.hided.where old_parent_id: id
    end

    def hided_parent_changed?
      sought_parent = hided_parent
      return false unless sought_parent

      # Existing parent (for hided node and child of hided) should be the same;
      # if not - means than child changed it parent
      grandparent = sought_parent.find_first_real_parent
      grandparent&.id != parent_id
    end

    def subtree_with_hided
      sub_ids = subtree.pluck(:id)
      ids_for_search = sub_ids + hided_descendants_ids
      self.class.where id: ids_for_search
      # TODO: add sort by hide_ancestry
    end

    def hided_parent
      sought_parent =
        self.class.hided.select do |u|
          u.old_child_ids.include? id
        end
      sought_parent.blank? ? nil : sought_parent.first
    end

    def hided_children_present?
      self.class.hided_childs(id).present?
    end

    def hided_descendants_ids
      ids = []
      iterate_desc_for_hided(ids) # TODO: Do I need this?
      iterate_hided_desc(ids)
      ids.uniq
    end

    def hided_ids
      self.class.hided.pluck(:id)
    end

    def find_first_real_parent
      parent_usr = self.class.find_by id: old_parent_id
      return parent unless parent_usr
      parent_usr.hided? ? parent_usr.find_first_real_parent : parent_usr
    end

    # Monkeypatching ActiveModel::Dirty method
    # to correct work of #previous_changes in model
    def changes_applied
      @previously_changed = @record_changes
      @changed_attributes = ActiveSupport::HashWithIndifferentAccess.new
    end

    protected

    def iterate_desc_for_hided(array)
      descendants.each do |user|
        user.hided_children.each { |child| array << child.id }
      end
    end

    def iterate_hided_desc(array)
      hided_children.each do |hided_child|
        array << hided_child.id
        hided_child.iterate_hided_desc(array)
      end
    end
  end
end