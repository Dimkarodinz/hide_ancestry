require 'spec_helper'

describe Bonobo, type: :model do
  it { is_expected.not_to have_db_column :hidden_status }

  it_behaves_like '.has_hide_ancestry owner'
  it_behaves_like 'hide_ancestry instance methods owner'
end