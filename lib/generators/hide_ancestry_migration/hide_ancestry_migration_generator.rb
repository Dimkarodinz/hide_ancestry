class HideAncestryMigrationGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  argument :table_name, type: :string
  class_option :hided_status,
                type: :boolean,
                default: true,
                desc: 'Create hided_status:boolean column'

  def create_migration_file
    generate "migration add_hide_ancestry_cols_to_#{table} #{arguments}"
  end

  private

  def table
    table_name.underscore
  end

  def arguments
    base_arguments + optional_argument.to_s
  end

  def base_arguments
    'old_parent_id:integer hide_ancestry:string '
  end

  def optional_argument
    'hided_status:boolean' if options.hided_status?
  end
end
