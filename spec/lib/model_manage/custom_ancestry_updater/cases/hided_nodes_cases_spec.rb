require 'spec_helper'

describe EmployeeManage::CustomAncestryUpdater do
  include_examples '.user factories'

  let(:root_user) { create :user }

  describe 'when #fired_status' do
    context 'does not change custom ancestry cols' do
      context 'of called node' do
        let!(:before_depth_col)         { parent.depth_level }
        let!(:before_ancestry_path_col) { parent.full_ancestry_path }

        before { EmployeeManage::Fire.call(parent) }

        it '#depth_level col' do
          expect(parent.reload.depth_level).to eq before_depth_col
        end

        it '#full_ancestry_path col' do
          expect(parent.reload.full_ancestry_path)
          .to eq before_ancestry_path_col
        end
      end

      context 'relatives of node' do
        let!(:prev_child_path)  { child.full_ancestry_path }
        let!(:prev_child_depth) { child.depth_level }
        let!(:prev_grand_path)  { grandparent.full_ancestry_path }
        let!(:prev_grand_depth) { grandparent.depth_level }

        before { EmployeeManage::Fire.call(parent) }

        it 'grandparent#full_ancestry_path col' do
          expect(grandparent.reload.full_ancestry_path).to eq prev_grand_path
        end

        it 'grandparent#full_ancestry_path col' do
          expect(grandparent.reload.depth_level).to eq prev_grand_depth
        end

        it 'child#depth_level col' do
          expect(child.reload.depth_level).to eq prev_child_depth
        end

        it 'child#full_ancestry_path col' do
          expect(child.reload.full_ancestry_path).to eq prev_child_path
        end
      end
    end

    context 'and parent of fired node changes its parent' do
      let!(:old_fired_depth) { parent.depth_level }
      let!(:old_fired_path)  { parent.full_ancestry_path_ids }

      let(:new_parent) { create :user }

      before do
        EmployeeManage::Fire.call(parent)
        grandparent.update parent: new_parent
      end

      it 'node#full_ancestry_path changes' do
        expect(parent.reload.full_ancestry_path_ids).to include new_parent.id
        expect(parent.full_ancestry_path_ids).not_to eq old_fired_path
      end

      it 'node#depth_level changes' do
        expect(parent.reload.depth_level).not_to eq old_fired_depth
        expect(parent.depth_level.length).to eq old_fired_depth.length + 2
      end
    end
  end

  describe 'and parent of fired node changes its parent' do
    let!(:old_fired_depth) { parent.depth_level }
    let!(:old_fired_path)  { parent.full_ancestry_path_ids }

    let(:new_parent) { create :user }

    before do
      EmployeeManage::Fire.call(parent)
      grandparent.update parent: new_parent
    end

    it 'node#full_ancestry_path changes' do
      expect(parent.reload.full_ancestry_path_ids).to include new_parent.id
      expect(parent.full_ancestry_path_ids).not_to eq old_fired_path
    end

    it 'node#depth_level changes' do
      expect(parent.reload.depth_level).not_to eq old_fired_depth
      expect(parent.depth_level.length).to eq old_fired_depth.length + 2
    end
  end

  describe do
    context 'fired parent, child changes path' do
      before do
        parent.do_fired!
        child.update parent: root_user
      end

      it { expect(child.reload.depth_level).to eq '1'}

      subject { child.reload.full_ancestry_path_ids }

      it { expect(subject).to include root_user.id }
      it { expect(subject).not_to include parent.id }
      it { expect(subject).not_to include grandparent.id }
    end

    context 'fired parent, child does not changes path' do
      before { parent.do_fired! }

      subject { child.reload.full_ancestry_path_ids }

      it { expect(subject).to include parent.id }
      it { expect(subject).to include grandparent.id }
    end
  end

  describe 'fired parent, changed subtree' do
    let!(:some_fired_user) { create :fired_user }

    before do
      parent.do_fired!
      grandparent.update parent: root_user
    end

    it 'changes #full_ancestry_path of subtree fired users' do
      expect(parent.reload.full_ancestry_path_ids).to include root_user.id
    end

    it 'changes #depth_level of subtree fired users' do
      expect(parent.reload.depth_level).not_to eq '1'
      expect(parent.depth_level).to eq '1.2'
    end

    it 'does not change #full_ancestry_path outer fired users' do
      expect(some_fired_user.full_ancestry_path_ids).to eq [some_fired_user.id]
      expect(some_fired_user.depth_level).to eq '0'
    end
  end
end