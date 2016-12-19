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

      cattr_accessor :hiden_column
      self.hiden_column = options[:use_column] || :hiden_status

      # Include validation errors to the model
      include Errors

      # Include instance methods to the model
      include InstanceMethods

      serialize :old_child_ids, Array

      scope :hiden,   -> { where hiden_column => true }
      scope :unhiden, -> { where.not(hiden_column => true) }
      scope :hiden_nodes,  -> (ids) { hiden.where id: ids }
      scope :hiden_childs, -> (some_id) { hiden.where old_parent_id: some_id }

      # Persist record changes for correct work of #previous_changes
      before_save do |record|
        @record_changes = record.changes
      end

      after_save do |record|
        ModelManage::CustomAncestryUpdater.call(record)
      end

      # hiden node can not change ancestry
      validate :can_not_has_parent_or_children_error, if: -> { hiden? }
    end
  end
end
