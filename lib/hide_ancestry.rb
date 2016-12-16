require 'ancestry'
Dir["hide_ancestry/**/*.rb"].each { |file| require file }

module HideAncestry
  extend ActiveSupport::Concern

  class_methods do
    def has_hide_ancestry options = {}
      # TODO:
      # => check if cols present
      # => exeptions

      # Include private validation errors to the model
      include HideAncestry::Errors

      # Include instance methods to the model
      include HideAncestry::InstanceMethods

      # Add ActiveRecord callbacks, scopes and validations
      # excule HideAncestry::ClassMethods

      scope :hided,   -> { where hided_status: true }
      scope :unhided, -> { where.not(hided_status: true) }
      scope :hided_users,  -> (ids) { fired.where id: ids }
      scope :hided_childs, -> (some_id) { fired.where old_parent_id: some_id }

      # Persist record changes for correct work of #previous_changes
      before_save do |record|
        @record_changes = record.changes
      end

      after_save do |record|
        HideAncestry::ModelManage::CustomAncestryUpdater.call(self)
      end

      # For node#hided? when it trying to change #parent_id
      validate :can_not_has_parent_or_children_error, if: -> { hided? }
    end
  end
end

# Include the extension 
ActiveRecord::Base.send(:include, HideAncestry)
