class AddAncestryToChimpanzees < ActiveRecord::Migration
  def change
    add_column :chimpanzees, :ancestry, :string
    add_index :chimpanzees, :ancestry
  end
end
