class <%=migration_class_name%> < ActiveRecord::Migration
  def change
    change_table :<%=table%> do |t|
      t.integer :old_parent_id
      t.text    :old_child_ids
      t.string  :hide_ancestry
      <%='t.boolean :hiden_status, default: false' if options.hiden_status?%>
    end
  end
end