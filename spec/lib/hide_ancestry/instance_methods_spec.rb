require 'spec_helper'

describe HideAncestry::InstanceMethods do
  include_examples 'Monkeys subtree'

  context '#hide' do
    it 'return #not_valid_error unless #valid?' do
      allow(parent).to receive(:valid?).and_return false
      parent.hide
      expect(parent.errors[:base].first).to include 'not valid'
    end

    it do
      expect(HideAncestry::ModelManage::Hide)
      .to receive(:call).with(parent)
      parent.hide
    end
  end

  context '#restore' do
    let(:hided) { create :hided_monkey }

    it 'return #not_valid_error unless #valid?' do
      allow(hided).to receive(:valid?).and_return false
      hided.restore
      expect(hided.errors[:base].first).to include 'not valid'
    end

    it 'return #already_restored_error unless hided' do
      parent.restore
      expect(parent.errors[:base].first).to include 'Already restored'
    end

    it do
      expect(HideAncestry::ModelManage::Restore)
      .to receive(:call).with(hided)
      hided.restore
    end
  end

  context '#first_hiding?' do
    it 'true when prev #old_parent_id was nil' do
      allow(parent).to receive(:previous_changes)
                          .and_return({'old_parent_id' => [nil, 1]})

      expect(parent.first_hiding?).to be_truthy
    end

    it 'nil when #old_parent_id no changes' do
      allow(parent).to receive_message_chain('previous_changes.[]')
                          .with('old_parent_id')
                          .and_return(nil)

      expect(parent.first_hiding?).to be_nil
    end

    it 'false when prev #old_parent_id not nil' do
      allow(parent).to receive(:previous_changes)
                          .and_return({'old_parent_id' => [1, 2]})
      expect(parent.first_hiding?).to eq false
    end
  end

  context '#hided_parent_changed?' do
    subject { child.reload.hided_parent_changed? }

    it 'true if node grandparent != hided parent old parent' do
      HideAncestry::ModelManage::Hide.call(parent)
      allow(child).to receive(:parent_id).and_return 111
      is_expected.to be_truthy
    end

    it 'false if node grandparent == hided parent old parent' do
      HideAncestry::ModelManage::Hide.call(parent)
      is_expected.to be_falsey
    end

    it 'false if no hided parent' do
      allow(child).to receive(:hided_parent).and_return nil
      is_expected.to be_falsey
    end
  end

  context '#hided_parent' do
    before { HideAncestry::ModelManage::Hide.call(grandparent) }

    it 'return record#hided? which ' \
       'includes node#id in #old_child_ids' do
      expect(parent.hided_parent).to eq grandparent
      expect(parent.reload.parent).to be_nil
    end

    it 'return nil if no record#hided? ' \
       'with node#id in #old_child_ids' do
      expect(child.hided_parent).to be_nil
    end
  end

  context '#hided_descendants_ids' do
    before { HideAncestry::ModelManage::Hide.call(parent) }

    it 'return ids nodes#hided?, ' \
       'which #old_parent_id eql to descendants ids' do

      expect(grandparent.hided_descendants_ids).to include parent.id
      expect(child.hided_descendants_ids).to be_blank
    end
  end

  context '#find_first_real_parent' do
    let(:new_monkey) { create :monkey }

    it 'find record by #old_parent_id' do
      HideAncestry::ModelManage::Hide.call(parent)

      expect(parent.reload.parent).to be_nil
      expect(parent.find_first_real_parent).to eq grandparent
    end

    it 'return #parent if #old_parent_id.nil?' do
      expect(child.find_first_real_parent).to eq parent
      expect(grandparent.find_first_real_parent).to be_nil
    end

    it 'call itself to finded if record#hided?' do
      HideAncestry::ModelManage::Hide.call(parent)
      HideAncestry::ModelManage::Hide.call(child)
      expect(child.find_first_real_parent).to eq grandparent
    end
  end
end