require 'spec_helper'

describe HideAncestry::Validators do
  let(:monkey)       { build :monkey }
  let(:hidden_monkey) { create :hidden_monkey }

  context '#can_not_has_parent_or_children' do
    it 'when ancestry changed' do
        error_message = 'hidden node can`t has any real parent or children'
        hidden_monkey.ancestry = '1/2/3'

        hidden_monkey.valid?
        expect(hidden_monkey.errors[:base]).to include error_message
    end
  end
end