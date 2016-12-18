require 'spec_helper'

describe HideAncestry::Errors do
  let(:monkey)       { build :monkey }
  let(:hided_monkey) { create :hided_monkey }

  context '#can_not_has_parent_or_children_error' do
    it 'when ancestry changed' do
        error_message = 'Hided node can`t has any real parent or children'
        hided_monkey.ancestry = '1/2/3'

        hided_monkey.valid?
        expect(hided_monkey.errors[:base]).to include error_message
    end
  end
end