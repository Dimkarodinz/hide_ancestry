class CreateChimpanzees < ActiveRecord::Migration
  def change
    create_table :chimpanzees do |t|

      t.timestamps null: false
    end
  end
end
