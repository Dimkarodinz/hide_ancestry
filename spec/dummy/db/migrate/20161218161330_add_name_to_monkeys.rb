class AddNameToMonkeys < ActiveRecord::Migration
  def change
    add_column :monkeys, :name, :string
  end
end
