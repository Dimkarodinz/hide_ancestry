require 'spec_helper'

describe EmployeeManage::CustomAncestryUpdater do
  include_examples '.user factories'

  context 'when parent fired, then grandparent#update' do
    let(:parent_info) { [parent.full_ancestry_path, parent.depth_level] }
    let(:child_info)  { [child.full_ancestry_path, child.depth_level] }
    let(:grand_info) do
      [grandparent.full_ancestry_path, grandparent.depth_level]
    end

    let(:do_updating) do
      EmployeeManage::Fire.call(parent)
      grandparent.update first_name: 'something'
    end

    it 'grandparent' do
      prev_grand_info = grand_info
      do_updating
      expect(
        [grandparent.full_ancestry_path, grandparent.depth_level]
        ).to eq prev_grand_info
    end

    it 'parent' do
      prev_parent_info = parent_info
      do_updating
      parent.reload
      expect(
        [parent.full_ancestry_path, parent.depth_level]
        ).to eq prev_parent_info
    end

    it 'child' do
      prev_child_info = child_info
      do_updating
      child.reload
      expect(
        [child.full_ancestry_path, child.depth_level]
        ).to eq prev_child_info
    end
  end  

  context 'when two users fired' do
    let!(:root_user) { create :user }

    before do
      grandparent.update parent: root_user
      EmployeeManage::Fire.call(parent)
      EmployeeManage::Fire.call(grandparent)
    end

    it { expect(child.reload.parent_id).to eq root_user.id }

    it 'substructure shifts correctly' do
      expect(root_user.reload.children.map(&:id)).to include child.id
    end

    context 'custom ancestry' do
      it '#parent has corrent custom ancestry' do
        parent.reload
        expect(parent.full_ancestry_path_ids)
        .to eq [root_user.id, grandparent.id, parent.id]
        expect(parent.depth_level).to eq '1.2'
      end

      it '#grandparent has corrent custom ancestry' do
        grandparent.reload
        expect(grandparent.full_ancestry_path_ids).to include root_user.id
        expect(grandparent.depth_level).to eq '1'
      end

      it '#child has correct custom ancestry' do
        child.reload
        expect(child.full_ancestry_path_ids)
        .to eq [root_user.id, grandparent.id, parent.id, child.id]
        expect(child.depth_level).to eq '1.2.3'
      end
    end
  end

  context 'custom ancestry cols' do
    let!(:grand_prev_anc_path)  { grandparent.reload.full_ancestry_path }
    let!(:grand_prev_depth_l)   { grandparent.reload.depth_level }

    let!(:parent_prev_anc_path) { parent.reload.full_ancestry_path }
    let!(:parent_prev_depth_l)  { parent.reload.depth_level }

    let!(:parent_prev_parent_id) { parent.parent_id }
    let!(:grandparent_prev_parent_id) { grandparent.parent_id }

    describe 'fired in natural order' do
      before do
        EmployeeManage::Fire.call(grandparent)
        EmployeeManage::Fire.call(parent)
      end

      context do
        before do
          EmployeeManage::Restore.call(grandparent)
          EmployeeManage::Restore.call(parent)
        end

        it_behaves_like 'successfully restored nodes'  
      end

      context do
        before do
          EmployeeManage::Restore.call(parent)
          EmployeeManage::Restore.call(grandparent)
        end

        it_behaves_like 'successfully restored nodes'
      end
    end

    describe 'fired in reverse order' do
      before do
        EmployeeManage::Fire.call(parent)
        EmployeeManage::Fire.call(grandparent)
      end

      context do
        before do
          EmployeeManage::Restore.call(grandparent)
          EmployeeManage::Restore.call(parent)
        end

        it_behaves_like 'successfully restored nodes'  
      end

      context do
        before do
          EmployeeManage::Restore.call(parent)
          EmployeeManage::Restore.call(grandparent)
        end

        it_behaves_like 'successfully restored nodes'
      end
    end
  end

  context 'substructure updated' do
    let!(:new_root) { create :user }

    subject { grandparent.update parent: new_root }

    it 'changes #full_ancestry_path' do
      subject
      expect(grandparent.reload.full_ancestry_path_ids).to include new_root.id
      expect(child.reload.full_ancestry_path_ids).to include new_root.id
    end

    it 'changes #depth_level' do
      expected_size = child.depth_level.size + 2
      subject
      expect(child.reload.depth_level.size).to eq expected_size
    end
  end

  describe 'child custom cols' do
    let!(:child_depth)    { child.depth_level }
    let!(:child_anc_path) { child.full_ancestry_path }

    before { EmployeeManage::Fire.call(grandparent) }

    it '#full_ancestry_path' do
      expect(child.reload.depth_level).to eq child_depth
    end

    it '#depth_level' do
      expect(child.reload.full_ancestry_path).to eq child_anc_path
    end
  end
end