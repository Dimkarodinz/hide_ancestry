module HideAncestry
  module Errors
    private

    def can_not_has_parent_or_children_error
      errors.add(
        :user, # fix
        "Hided use #{'thing'} can`t has any real parent or children"
        ) if self.ancestry.present?
    end

    def already_restored_error
      errors.add :user,  'Already restored' # fix
    end

    def not_valid_error
      errors.add :user, "#{self.class} not valid" # fix
    end
  end
end