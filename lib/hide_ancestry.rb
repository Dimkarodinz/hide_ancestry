require 'ancestry'

require 'hide_ancestry/engine'
require 'hide_ancestry/errors'
require 'hide_ancestry/instance_methods'
require 'hide_ancestry/exeptions'

require 'hide_ancestry/model_manage/base'
require 'hide_ancestry/model_manage/custom_ancestry_updater'
require 'hide_ancestry/model_manage/hide'
require 'hide_ancestry/model_manage/restore'

module HideAncestry
  extend ActiveSupport::Concern
  class_methods do
    def has_hide_ancestry options = {}
      # Check options
      raise HideAncestryExeption.new(
        'Options for has_hide_ancestry must be in a hash'
        ) unless options.is_a? Hash

      options.each do |key, value|
        unless [:use_column].include? key
          raise HideAncestryExeption.new(
            "Unknown option for has_hide_ancestry: " \
            "#{key.inspect} => #{value.inspect}"
            )
        end
      end

      cattr_accessor :hided_column
      self.hided_column = options[:use_column] || :hided_status

      # Include validation errors to the model
      include Errors

      # Include instance methods to the model
      include InstanceMethods

      serialize :old_child_ids, Array

      scope :hided,   -> { where hided_column => true }
      scope :unhided, -> { where.not(hided_column => true) }
      scope :hided_nodes,  -> (ids) { hided.where id: ids }
      scope :hided_childs, -> (some_id) { hided.where old_parent_id: some_id }

      # Persist record changes for correct work of #previous_changes
      before_save do |record|
        @record_changes = record.changes
      end

      after_save do |record|
        ModelManage::CustomAncestryUpdater.call(record)
      end

      # Hided node can not change ancestry
      validate :can_not_has_parent_or_children_error, if: -> { hided? }
    end
  end
end
