require 'spec_helper'

describe HideAncestry::ModelManage::CustomAncestryUpdater do
  include_examples 'Monkeys subtree'

  let(:root_monkey) { create :monkey }

  describe 'when #hided_status' do
    context 'does not change custom ancestry cols' do
      context 'of called node' do
        let!(:before_depth_col)     { parent.depth_level }
        let!(:before_hide_ancestry) { parent.hide_ancestry }

        before { HideAncestry::ModelManage::Hide.call(parent) }

        it '#depth_level col' do
          expect(parent.reload.depth_level).to eq before_depth_col
        end

        it '#hide_ancestry col' do
          expect(parent.reload.hide_ancestry)
          .to eq before_hide_ancestry
        end
      end

      context 'relatives of node' do
        let!(:prev_child_path)  { child.hide_ancestry }
        let!(:prev_child_depth) { child.depth_level }
        let!(:prev_grand_path)  { grandparent.hide_ancestry }
        let!(:prev_grand_depth) { grandparent.depth_level }

        before { HideAncestry::ModelManage::Hide.call(parent) }

        it 'grandparent#hide_ancestry col' do
          expect(grandparent.reload.hide_ancestry).to eq prev_grand_path
        end

        it 'grandparent#hide_ancestry col' do
          expect(grandparent.reload.depth_level).to eq prev_grand_depth
        end

        it 'child#depth_level col' do
          expect(child.reload.depth_level).to eq prev_child_depth
        end

        it 'child#hide_ancestry col' do
          expect(child.reload.hide_ancestry).to eq prev_child_path
        end
      end
    end

    context 'and parent of hided node changes its parent' do
      let!(:old_hided_depth) { parent.depth_level }
      let!(:old_hided_path)  { parent.hide_ancestry_ids }

      let(:new_parent) { create :monkey }

      before do
        HideAncestry::ModelManage::Hide.call(parent)
        grandparent.update parent: new_parent
      end

      it 'node#hide_ancestry changes' do
        expect(parent.reload.hide_ancestry_ids).to include new_parent.id
        expect(parent.hide_ancestry_ids).not_to eq old_hided_path
      end

      it 'node#depth_level changes' do
        expect(parent.reload.depth_level).not_to eq old_hided_depth
        expect(parent.depth_level.length).to eq old_hided_depth.length + 2
      end
    end
  end

  describe 'and parent of hided node changes its parent' do
    let!(:old_hided_depth) { parent.depth_level }
    let!(:old_hided_path)  { parent.hide_ancestry_ids }

    let(:new_parent) { create :monkey }

    before do
      HideAncestry::ModelManage::Hide.call(parent)
      grandparent.update parent: new_parent
    end

    it 'node#hide_ancestry changes' do
      expect(parent.reload.hide_ancestry_ids).to include new_parent.id
      expect(parent.hide_ancestry_ids).not_to eq old_hided_path
    end

    it 'node#depth_level changes' do
      expect(parent.reload.depth_level).not_to eq old_hided_depth
      expect(parent.depth_level.length).to eq old_hided_depth.length + 2
    end
  end

  describe do
    context 'hided parent, child changes path' do
      before do
        parent.hide
        child.update parent: root_monkey
      end

      it { expect(child.reload.depth_level).to eq '1'}

      subject { child.reload.hide_ancestry_ids }

      it { expect(subject).to include root_monkey.id }
      it { expect(subject).not_to include parent.id }
      it { expect(subject).not_to include grandparent.id }
    end

    context 'hided parent, child does not changes path' do
      before { parent.hide }

      subject { child.reload.hide_ancestry_ids }

      it { expect(subject).to include parent.id }
      it { expect(subject).to include grandparent.id }
    end
  end

  describe 'hided parent, changed subtree' do
    let!(:some_hided_monkey) { create :hided_monkey }

    before do
      parent.hide
      grandparent.update parent: root_monkey
    end

    it 'changes #hide_ancestry of subtree hided monkeys' do
      expect(parent.reload.hide_ancestry_ids).to include root_monkey.id
    end

    it 'changes #depth_level of subtree hided monkeys' do
      expect(parent.reload.depth_level).not_to eq '1'
      expect(parent.depth_level).to eq '1.2'
    end

    it 'does not change #hide_ancestry outer hided monkeys' do
      expect(some_hided_monkey.hide_ancestry_ids).to eq [some_hided_monkey.id]
      expect(some_hided_monkey.depth_level).to eq '0'
    end
  end
end