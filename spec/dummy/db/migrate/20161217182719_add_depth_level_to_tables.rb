class AddDepthLevelToTables < ActiveRecord::Migration
  def change
    add_column :monkeys, :depth_level, :string
    add_column :bonobos, :depth_level, :string
    add_column :chimpanzees, :depth_level, :string
  end
end
