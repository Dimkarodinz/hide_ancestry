require 'spec_helper'

describe HideAncestry::ModelManage::CustomAncestryUpdater do
  include_examples 'Monkeys subtree'

  let(:root_monkey) { create :monkey }

  describe 'when #hiden_status' do
    context 'does not change custom ancestry cols' do
      context 'of called node' do
        let!(:before_hide_ancestry) { parent.hide_ancestry }

        before { HideAncestry::ModelManage::Hide.call(parent) }

        it '#hide_ancestry col' do
          expect(parent.reload.hide_ancestry)
          .to eq before_hide_ancestry
        end
      end

      context 'relatives of node' do
        let!(:prev_child_path)  { child.hide_ancestry }
        let!(:prev_grand_path)  { grandparent.hide_ancestry }

        before { HideAncestry::ModelManage::Hide.call(parent) }

        it 'grandparent#hide_ancestry col' do
          expect(grandparent.reload.hide_ancestry).to eq prev_grand_path
        end

        it 'child#hide_ancestry col' do
          expect(child.reload.hide_ancestry).to eq prev_child_path
        end
      end
    end

    context 'and parent of hiden node changes its parent' do
      let!(:old_hiden_path)  { parent.hide_ancestry_ids }

      let(:new_parent) { create :monkey }

      before do
        HideAncestry::ModelManage::Hide.call(parent)
        grandparent.update parent: new_parent
      end

      it 'node#hide_ancestry changes' do
        expect(parent.reload.hide_ancestry_ids).to include new_parent.id
        expect(parent.hide_ancestry_ids).not_to eq old_hiden_path
      end
    end
  end

  describe 'and parent of hiden node changes its parent' do
    let!(:old_hiden_path)  { parent.hide_ancestry_ids }

    let(:new_parent) { create :monkey }

    before do
      HideAncestry::ModelManage::Hide.call(parent)
      grandparent.update parent: new_parent
    end

    it 'node#hide_ancestry changes' do
      expect(parent.reload.hide_ancestry_ids).to include new_parent.id
      expect(parent.hide_ancestry_ids).not_to eq old_hiden_path
    end
  end

  describe do
    context 'hiden parent, child changes path' do
      before do
        parent.hide
        child.update parent: root_monkey
      end

      subject { child.reload.hide_ancestry_ids }

      it { expect(subject).to include root_monkey.id }
      it { expect(subject).not_to include parent.id }
      it { expect(subject).not_to include grandparent.id }
    end

    context 'hiden parent, child does not changes path' do
      before { parent.hide }

      subject { child.reload.hide_ancestry_ids }

      it { expect(subject).to include parent.id }
      it { expect(subject).to include grandparent.id }
    end
  end

  describe 'hiden parent, changed subtree' do
    let!(:some_hiden_monkey) { create :hiden_monkey }

    before do
      parent.hide
      grandparent.update parent: root_monkey
    end

    it 'changes #hide_ancestry of subtree hiden monkeys' do
      expect(parent.reload.hide_ancestry_ids).to include root_monkey.id
    end
  end
end