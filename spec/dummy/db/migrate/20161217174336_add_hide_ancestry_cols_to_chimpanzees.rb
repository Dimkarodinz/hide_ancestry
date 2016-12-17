class AddHideAncestryColsToChimpanzees < ActiveRecord::Migration
  def change
    change_table :chimpanzees do |t|
      t.integer :old_parent_id
      t.text    :old_child_ids
      t.string  :hide_ancestry
      t.boolean :hided_status, default: false
    end
  end
end