require 'spec_helper'

describe Monkey, type: :model do
  it_behaves_like '.has_hide_ancestry owner'
  it_behaves_like 'hide_ancestry instance methods owner'
end