require 'spec_helper'

describe HideAncestry::Validators do
  let(:monkey)       { build :monkey }
  let(:hiden_monkey) { create :hiden_monkey }

  context '#can_not_has_parent_or_children' do
    it 'when ancestry changed' do
        error_message = 'hiden node can`t has any real parent or children'
        hiden_monkey.ancestry = '1/2/3'

        hiden_monkey.valid?
        expect(hiden_monkey.errors[:base]).to include error_message
    end
  end
end