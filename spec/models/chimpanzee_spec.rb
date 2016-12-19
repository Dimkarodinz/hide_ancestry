require 'spec_helper'

describe Chimpanzee, type: :model do
  it_behaves_like '.has_hide_ancestry owner', 'expecting erorrs'
  it_behaves_like 'hide_ancestry instance methods owner', 'expecting erorrs'
end