require 'ancestry'

require 'hide_ancestry/engine'
require 'hide_ancestry/errors'
require 'hide_ancestry/instance_methods'

require 'hide_ancestry/model_manage/base'
require 'hide_ancestry/model_manage/custom_ancestry_updater'
require 'hide_ancestry/model_manage/fire'
require 'hide_ancestry/model_manage/restore'

module HideAncestry
  extend ActiveSupport::Concern

  class_methods do
    def has_hide_ancestry options = {}
      # TODO: delete depth_level col

      # Include private validation errors to the model
      include Errors

      # Include instance methods to the model
      include InstanceMethods

      serialize :old_child_ids, Array

      scope :hided,   -> { where hided_status: true }
      scope :unhided, -> { where.not(hided_status: true) }
      scope :hided_users,  -> (ids) { hided.where id: ids }
      scope :hided_childs, -> (some_id) { hided.where old_parent_id: some_id }

      # Persist record changes for correct work of #previous_changes
      before_save do |record|
        @record_changes = record.changes
      end

      after_save do |record|
        ModelManage::CustomAncestryUpdater.call(self)
      end

      # For node#hided? when it trying to change #parent_id
      validate :can_not_has_parent_or_children_error, if: -> { hided? }
    end
  end
end
