class CreateBonobos < ActiveRecord::Migration
  def change
    create_table :bonobos do |t|

      t.timestamps null: false
    end
  end
end
