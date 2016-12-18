require 'spec_helper'

describe HideAncestry::ModelManage::CustomAncestryUpdater do
  include_examples 'Monkeys subtree'

  context 'when parent fired, then grandparent#update' do
    let(:parent_info) { [parent.hide_ancestry, parent.depth_level] }
    let(:child_info)  { [child.hide_ancestry, child.depth_level] }
    let(:grand_info) do
      [grandparent.hide_ancestry, grandparent.depth_level]
    end

    let(:do_updating) do
      HideAncestry::ModelManage::Hide.call(parent)
      grandparent.update name: 'something' ####
    end

    it 'grandparent' do
      prev_grand_info = grand_info
      do_updating
      expect(
        [grandparent.hide_ancestry, grandparent.depth_level]
        ).to eq prev_grand_info
    end

    it 'parent' do
      prev_parent_info = parent_info
      do_updating
      parent.reload
      expect(
        [parent.hide_ancestry, parent.depth_level]
        ).to eq prev_parent_info
    end

    it 'child' do
      prev_child_info = child_info
      do_updating
      child.reload
      expect(
        [child.hide_ancestry, child.depth_level]
        ).to eq prev_child_info
    end
  end  

  context 'when two users fired' do
    let!(:root_monkey) { create :monkey }

    before do
      grandparent.update parent: root_monkey
      HideAncestry::ModelManage::Hide.call(parent)
      HideAncestry::ModelManage::Hide.call(grandparent)
    end

    it { expect(child.reload.parent_id).to eq root_monkey.id }

    it 'substructure shifts correctly' do
      expect(root_monkey.reload.children.map(&:id)).to include child.id
    end

    context 'custom ancestry' do
      it '#parent has corrent custom ancestry' do
        parent.reload
        expect(parent.hide_ancestry_ids)
        .to eq [root_monkey.id, grandparent.id, parent.id]
        expect(parent.depth_level).to eq '1.2'
      end

      it '#grandparent has corrent custom ancestry' do
        grandparent.reload
        expect(grandparent.hide_ancestry_ids).to include root_monkey.id
        expect(grandparent.depth_level).to eq '1'
      end

      it '#child has correct custom ancestry' do
        child.reload
        expect(child.hide_ancestry_ids)
        .to eq [root_monkey.id, grandparent.id, parent.id, child.id]
        expect(child.depth_level).to eq '1.2.3'
      end
    end
  end

  context 'custom ancestry cols' do
    let!(:grand_prev_anc_path)  { grandparent.reload.hide_ancestry }
    let!(:grand_prev_depth_l)   { grandparent.reload.depth_level }

    let!(:parent_prev_anc_path) { parent.reload.hide_ancestry }
    let!(:parent_prev_depth_l)  { parent.reload.depth_level }

    let!(:parent_prev_parent_id) { parent.parent_id }
    let!(:grandparent_prev_parent_id) { grandparent.parent_id }

    describe 'fired in natural order' do
      before do
        HideAncestry::ModelManage::Hide.call(grandparent)
        HideAncestry::ModelManage::Hide.call(parent)
      end

      context do
        before do
          HideAncestry::ModelManage::Restore.call(grandparent)
          HideAncestry::ModelManage::Restore.call(parent)
        end

        it_behaves_like 'successfully restored nodes'  
      end

      context do
        before do
          HideAncestry::ModelManage::Restore.call(parent)
          HideAncestry::ModelManage::Restore.call(grandparent)
        end

        it_behaves_like 'successfully restored nodes'
      end
    end

    describe 'fired in reverse order' do
      before do
        HideAncestry::ModelManage::Hide.call(parent)
        HideAncestry::ModelManage::Hide.call(grandparent)
      end

      context do
        before do
          HideAncestry::ModelManage::Restore.call(grandparent)
          HideAncestry::ModelManage::Restore.call(parent)
        end

        it_behaves_like 'successfully restored nodes'  
      end

      context do
        before do
          HideAncestry::ModelManage::Restore.call(parent)
          HideAncestry::ModelManage::Restore.call(grandparent)
        end

        it_behaves_like 'successfully restored nodes'
      end
    end
  end

  context 'substructure updated' do
    let!(:new_root) { create :monkey }

    subject { grandparent.update parent: new_root }

    it 'changes #hide_ancestry' do
      subject
      expect(grandparent.reload.hide_ancestry_ids).to include new_root.id
      expect(child.reload.hide_ancestry_ids).to include new_root.id
    end

    it 'changes #depth_level' do
      expected_size = child.depth_level.size + 2
      subject
      expect(child.reload.depth_level.size).to eq expected_size
    end
  end

  describe 'child custom cols' do
    let!(:child_depth)    { child.depth_level }
    let!(:child_anc_path) { child.hide_ancestry }

    before { HideAncestry::ModelManage::Hide.call(grandparent) }

    it '#hide_ancestry' do
      expect(child.reload.depth_level).to eq child_depth
    end

    it '#depth_level' do
      expect(child.reload.hide_ancestry).to eq child_anc_path
    end
  end
end