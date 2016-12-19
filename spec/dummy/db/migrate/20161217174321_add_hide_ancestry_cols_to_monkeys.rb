class AddHideAncestryColsToMonkeys < ActiveRecord::Migration
  def change
    change_table :monkeys do |t|
      t.integer :old_parent_id
      t.text    :old_child_ids
      t.string  :hide_ancestry
      t.boolean :hiden_status, default: false
    end
  end
end