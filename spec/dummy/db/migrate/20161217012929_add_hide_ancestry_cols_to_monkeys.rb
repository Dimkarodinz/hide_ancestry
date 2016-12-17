class AddHideAncestryColsToMonkeys < ActiveRecord::Migration
  def change
    change_table :monkeys do |t|
      t.integer :old_parent_id
      t.string  :hide_ancestry
      t.boolean :hided_status, default: false
    end
  end
end