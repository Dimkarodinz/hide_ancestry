class Bonobo < ActiveRecord::Base
  # Model with custom has_hide_ancesty settings
  has_ancestry
  has_hide_ancesty use_column: :bonobo_status, readable_depth: true
end
