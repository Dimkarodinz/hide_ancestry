class HideAncestryMigrationGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root  File.expand_path('../templates', __FILE__)
  argument     :table_name, type: :string

  class_option :hiden_status,
                type: :boolean,
                default: true,
                desc: 'Create hiden_status:boolean column'

  def create_migration_file_in_app
    migration_template(
      'hide_ancestry_migration.rb',
      "db/migrate/add_hide_ancestry_cols_to_#{table}.rb"
      )
  end

  private

  # Fix 'next_migration_number' error
  def self.next_migration_number(path)
    unless @prev_migration_nr
      @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
    else
      @prev_migration_nr += 1
    end
    @prev_migration_nr.to_s
  end

  def table
    table_name.underscore
  end

  def migration_class_name
    "AddHideAncestryColsTo#{table_name.camelize}"
  end
end
