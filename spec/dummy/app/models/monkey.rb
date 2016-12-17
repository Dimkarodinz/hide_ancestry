class Monkey < ActiveRecord::Base
  # Model with default hide_ancestry settings
  has_ancestry
  has_hide_ancestry
end
