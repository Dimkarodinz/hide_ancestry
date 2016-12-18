require 'spec_helper'

describe Bonobo, type: :model do
  it { is_expected.not_to have_db_column :hided_status }

  # it_behaves_like '.has_hide_ancestry success owner', described_class
  # it_behaves_like 'hide_ancestry instance methods owner', described_class
  # it_behaves_like 'hide_ancestry model errors owner', descibed_class
end