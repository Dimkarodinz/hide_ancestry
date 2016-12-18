require 'spec_helper'

describe HideAncestry::ModelManage::CustomAncestryUpdater do
  include_examples 'Monkeys subtree'

  context 'custom ancestry cols' do
    let!(:grand_prev_anc_path)  { grandparent.reload.hide_ancestry }
    let!(:parent_prev_anc_path) { parent.reload.hide_ancestry }
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
  end

  describe 'child custom cols' do
    let!(:child_anc_path) { child.hide_ancestry }

    before { HideAncestry::ModelManage::Hide.call(grandparent) }

    it '#hide_ancestry' do
      expect(child.reload.hide_ancestry).to eq child_anc_path
    end
  end
end