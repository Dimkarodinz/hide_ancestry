class AddHideAncestryColsToBonobos < ActiveRecord::Migration
  def change
    change_table :bonobos do |t|
      t.integer :old_parent_id
      t.text    :old_child_ids
      t.string  :hide_ancestry
      
    end
  end
end