class AddHideBonoboToBonobos < ActiveRecord::Migration
  def change
    add_column :bonobos, :hide_bonobo, :boolean, default: false
  end
end
