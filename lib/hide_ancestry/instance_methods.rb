module HideAncestry
  module InstanceMethods
    def hide
      return not_valid unless valid?
      HideAncestry::ModelManage::Hide.call(self)
    end

    def restore
      return not_valid unless valid?
      return already_restored unless public_send(hiden_column) == true
      HideAncestry::ModelManage::Restore.call(self)
    end

    def first_hiding?
      old_parent_changes = previous_changes['old_parent_id']
      return unless old_parent_changes
      old_parent_changes.first.nil?
    end

    def hiden?
      self.public_send(hiden_column) == true
    end

    def hide_ancestry_ids
      hide_ancestry.split('/').map(&:to_i) if hide_ancestry
    end

    def children_of_hiden
      self.class.where id: old_child_ids
    end

    def hiden_children
      self.class.hiden.where old_parent_id: id
    end

    def hiden_parent_changed?
      sought_parent = hiden_parent
      return false unless sought_parent

      # Existing parent (for hiden node and child of hiden) should be the same;
      # if not - means than child changed it parent
      grandparent = sought_parent.find_first_real_parent
      grandparent&.id != parent_id
    end

    def subtree_with_hiden
      sub_ids = subtree.pluck(:id)
      ids_for_search = sub_ids + hiden_descendants_ids
      relation = self.class.where id: ids_for_search
      relation.order(hide_ancestry: :asc)
    end

    def depth_with_hiden
      hide_ancestry_ids.size
    end

    def hiden_parent
      sought_parent =
        self.class.hiden.select do |u|
          u.old_child_ids.include? id
        end
      sought_parent.blank? ? nil : sought_parent.first
    end

    def hiden_children_present?
      self.class.hiden_childs(id).present?
    end

    def hiden_descendants_ids
      ids = []
      iterate_desc_for_hiden(ids)
      iterate_hiden_desc(ids)
      ids.uniq
    end

    def hiden_ids
      self.class.hiden.pluck(:id)
    end

    def find_first_real_parent
      parent_usr = self.class.find_by id: old_parent_id
      return parent unless parent_usr
      parent_usr.hiden? ? parent_usr.find_first_real_parent : parent_usr
    end

    # Monkeypatching ActiveModel::Dirty method
    # to correct work of #previous_changes in model
    def changes_applied
      @previously_changed = @record_changes
      @changed_attributes = ActiveSupport::HashWithIndifferentAccess.new
    end

    protected

    def iterate_desc_for_hiden(array)
      descendants.each do |user|
        user.hiden_children.each { |child| array << child.id }
      end
    end

    def iterate_hiden_desc(array)
      hiden_children.each do |hiden_child|
        array << hiden_child.id
        hiden_child.iterate_hiden_desc(array)
      end
    end
  end
end