module HideAncestry
  module Errors
    private

    def can_not_has_parent_or_children_error
      errors.add(
        :base,
        "Hided node can`t has any real parent or children"
        ) if self.ancestry.present?
    end

    def already_restored_error
      errors.add :base, 'Already restored'
    end

    def not_valid_error
      errors.add :base, "#{self.class} not valid"
    end
  end
end