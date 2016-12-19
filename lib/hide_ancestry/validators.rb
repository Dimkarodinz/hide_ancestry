module HideAncestry
  module Validators
    private

    def can_not_has_parent_or_children
      errors.add(
        :base,
        "hidden node can`t has any real parent or children"
        ) if self.ancestry.present?
    end

    def already_restored
      errors.add :base, 'Already restored'
    end

    def not_valid
      errors.add :base, "#{self.class} is not valid"
    end
  end
end