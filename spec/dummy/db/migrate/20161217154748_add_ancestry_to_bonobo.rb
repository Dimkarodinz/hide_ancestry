class AddAncestryToBonobo < ActiveRecord::Migration
  def change
    add_column :bonobos, :ancestry, :string
    add_index :bonobos, :ancestry
  end
end
