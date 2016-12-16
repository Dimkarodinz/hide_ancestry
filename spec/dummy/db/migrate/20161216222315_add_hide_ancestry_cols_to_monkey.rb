class AddHideAncestryColsToMonkey < ActiveRecord::Migration
  def change
    add_column :monkeys, :old_parent_id, :integer
    add_column :monkeys, :hide_ancestry, :string
  end
end
