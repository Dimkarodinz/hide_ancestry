class Chimpanzee < ActiveRecord::Base
  # Model without ancestry, but with hide_ancestry
  # Exeptions expected
  has_hide_ancestry
end
