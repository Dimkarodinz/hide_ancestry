class AddAncestryToMonkeys < ActiveRecord::Migration
  def change
    add_column :monkeys, :ancestry, :string
    add_index :monkeys, :ancestry
  end
end
