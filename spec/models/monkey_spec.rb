require 'spec_helper'

describe Monkey, type: :model do
  it_behaves_like '.has_hide_ancestry success owner', described_class
  it_behaves_like 'hide_ancestry instance methods owner', described_class
  # it_behaves_like 'hide_ancestry model errors owner', descibed_class
end