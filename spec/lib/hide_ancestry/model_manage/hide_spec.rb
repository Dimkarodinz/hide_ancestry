require 'spec_helper'

describe HideAncestry::ModelManage::Hide do
  include_examples 'Monkeys subtree'
  let(:some_monkey) { create :monkey }

  context '#call' do
    subject { described_class.new(parent) }
    after   { subject.call }

    it { is_expected.to receive(:change_hiden_status).with(true) }
    it { is_expected.to receive :save_parent_id }
    it { is_expected.to receive :save_child_ids }

    it { is_expected.to receive :orphan_children }
    it { is_expected.to receive :clean_ancestry }
  end

  describe 'set' do
    before { described_class.call(parent) }

    it '#hiden_status to true' do
      expect(parent.hiden_status).to eq true
    end

    it '#ancestry to nil' do
      expect(parent.ancestry).to be_nil
    end
  end

  context 'set each children #parent_id to' do
    subject { child.reload.parent_id }

    it 'self#parent_id' do
      described_class.call(parent)
      is_expected.to eq grandparent.id
    end

    it 'first real parent if actual parent #hiden?' do
      grandparent.update(parent: some_monkey)
      described_class.call(grandparent)

      described_class.call(parent)
      is_expected.to eq some_monkey.id
    end

    it 'nil if no parent' do
      allow(parent).to receive(:parent).and_return nil
      described_class.call(parent)
      is_expected.to be_nil
    end

    it '#parent if no #old_parent_id' do
      allow(parent).to receive(:old_parent_id).and_return nil
      described_class.call(parent)
      is_expected.to eq grandparent.id
    end
  end

  context 'save children ids' do
    subject { parent.old_child_ids }

    it 'to #old_child_ids' do
      described_class.call(parent)
      is_expected.to include child.id
    end

    it 'of previously hiden children' do
      some_monkey.update parent_id: parent.id
      parent.reload

      described_class.call(some_monkey)
      expect(parent.child_ids).not_to include some_monkey.id

      described_class.call(parent)
      is_expected.to include some_monkey.id
    end
  end

  context 'save #parent_id' do
    subject { parent.old_parent_id }

    it 'to #old_parent_id' do
      described_class.call(parent)
      is_expected.to eq grandparent.id
    end

    it 'of hiden parent if present' do
      grandparent.update parent: some_monkey
      described_class.call(grandparent)

      expect(parent.reload.parent).to eq some_monkey

      described_class.call(parent)
      is_expected.to eq grandparent.id 
    end
  end
end