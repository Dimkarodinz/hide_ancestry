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
    let(:hiden) { create :hiden_monkey }

    it 'return #not_valid_error unless #valid?' do
      allow(hiden).to receive(:valid?).and_return false
      hiden.restore
      expect(hiden.errors[:base].first).to include 'not valid'
    end

    it 'return #already_restored_error unless hiden' do
      parent.restore
      expect(parent.errors[:base].first).to include 'Already restored'
    end

    it do
      expect(HideAncestry::ModelManage::Restore)
      .to receive(:call).with(hiden)
      hiden.restore
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

  context '#hiden_parent_changed?' do
    subject { child.reload.hiden_parent_changed? }

    it 'true if node grandparent != hiden parent old parent' do
      HideAncestry::ModelManage::Hide.call(parent)
      allow(child).to receive(:parent_id).and_return 111
      is_expected.to be_truthy
    end

    it 'false if node grandparent == hiden parent old parent' do
      HideAncestry::ModelManage::Hide.call(parent)
      is_expected.to be_falsey
    end

    it 'false if no hiden parent' do
      allow(child).to receive(:hiden_parent).and_return nil
      is_expected.to be_falsey
    end
  end

  context '#hiden_parent' do
    before { HideAncestry::ModelManage::Hide.call(grandparent) }

    it 'return record#hiden? which ' \
       'includes node#id in #old_child_ids' do
      expect(parent.hiden_parent).to eq grandparent
      expect(parent.reload.parent).to be_nil
    end

    it 'return nil if no record#hiden? ' \
       'with node#id in #old_child_ids' do
      expect(child.hiden_parent).to be_nil
    end
  end

  context '#hiden_descendants_ids' do
    before { HideAncestry::ModelManage::Hide.call(parent) }

    it 'return ids nodes#hiden?, ' \
       'which #old_parent_id eql to descendants ids' do

      expect(grandparent.hiden_descendants_ids).to include parent.id
      expect(child.hiden_descendants_ids).to be_blank
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

    it 'call itself to finded if record#hiden?' do
      HideAncestry::ModelManage::Hide.call(parent)
      HideAncestry::ModelManage::Hide.call(child)
      expect(child.find_first_real_parent).to eq grandparent
    end
  end

  context '#depth_with_hiden' do
    it 'return #size of #hide_ancestry_ids' do
      ids = [1, 2, 3]
      allow(parent).to receive(:hide_ancestry_ids).and_return(ids)
      expect(parent.depth_with_hiden).to eq 3
    end
  end

  context '#hide_ancestry_ids' do
    it 'returns #hide_ancestry as array' do
      custom_hide_ancestry = '1/2/3'

      allow(parent).to receive(:hide_ancestry).and_return(custom_hide_ancestry)
      expect(parent.hide_ancestry_ids).to eq [1,2,3] 
    end
  end

  context '#subtree_with_hiden' do
    it 'calls subtree ids as array' do
      expect(parent).to receive_message_chain('subtree.pluck')
                        .with(:id)
                        .and_return []

      parent.subtree_with_hiden
    end

    context 'return ordered relation' do
      let(:relation) { grandparent.subtree_with_hiden }

      after do
        expect(relation.first.id).to eq grandparent.id
        expect(relation.second.id).to eq parent.id
        expect(relation.last.id).to eq child.id
      end

      it 'returns ordered relation' do
        relation
      end

      it 'return ordered relation even node is hiden' do
        parent.hide
        relation
      end
    end
  end
end