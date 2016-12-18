class Bonobo < ActiveRecord::Base
  # Model with custom has_hide_ancesty settings
  has_ancestry
  has_hide_ancestry use_column: :hide_bonobo
end
