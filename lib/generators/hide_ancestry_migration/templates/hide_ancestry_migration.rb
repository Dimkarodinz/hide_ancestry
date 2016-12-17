class <%=migration_class_name%> < ActiveRecord::Migration
  def change
    change_table :<%=table%> do |t|
      t.integer :old_parent_id
      t.string  :hide_ancestry
      <%='t.boolean :hided_status, default: false' if options.hided_status?%>
    end
  end
end