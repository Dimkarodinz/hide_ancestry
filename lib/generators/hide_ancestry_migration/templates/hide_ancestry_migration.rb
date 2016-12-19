class <%=migration_class_name%> < ActiveRecord::Migration
  def change
    change_table :<%=table%> do |t|
      t.integer :old_parent_id
      t.text    :old_child_ids
      t.string  :hide_ancestry
      <%='t.boolean :hidden_status, default: false' if options.hidden_status?%>
    end
  end
end