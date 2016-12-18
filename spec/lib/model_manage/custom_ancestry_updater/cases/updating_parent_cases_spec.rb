require 'spec_helper'

describe HideAncestry::ModelManage::CustomAncestryUpdater do
  include_examples 'Monkeys subtree'

  describe 'when node#parent changed' do
    describe 'update custom ancestry cols' do
      let!(:root_monkey) { create :monkey }

      let!(:old_path_ids) { grandparent.hide_ancestry_ids }
      let!(:old_depth)    { grandparent.depth_level }

      let!(:old_parent_path_ids) { parent.hide_ancestry_ids }
      let!(:old_child_path_ids)  { child.hide_ancestry_ids }

      let!(:old_parent_depth) { parent.depth_level }
      let!(:old_child_depth)  { child.depth_level }

      before { grandparent.update parent: root_monkey }

      it 'node#hide_ancestry' do
        expect(grandparent.reload.hide_ancestry_ids)
        .not_to eq old_path_ids
        expect(grandparent.hide_ancestry_ids).to include root_monkey.id
      end

      it 'node#depth_level' do
        expect(grandparent.reload.depth_level).not_to eq old_depth
        expect(grandparent.depth_level).to eq '1'
      end

      context 'of node#descendants' do
        describe '#hide_ancestry of' do
          it 'parent' do
            expect(parent.reload.hide_ancestry_ids)
            .not_to eq old_parent_path_ids

            expect(parent.hide_ancestry_ids).to include root_monkey.id
          end

          it 'child' do
            expect(child.reload.hide_ancestry_ids)
            .not_to eq old_child_path_ids

            expect(child.hide_ancestry_ids).to include root_monkey.id
          end
        end

        describe '#depth_level of' do
          it 'parent' do
            expect(parent.reload.depth_level).not_to eq old_parent_depth
            expect(parent.depth_level.length).to eq old_parent_depth.length + 2
          end

          it 'child' do
            expect(child.reload.depth_level).not_to eq old_child_depth
            expect(child.depth_level.length).to eq old_child_depth.length + 2
          end
        end
      end
    end
  end

  describe 'changing parent' do
    context 'of node' do
      subject { parent.update parent: nil }

      context 'update child' do
        before { subject }

        it '#hide_ancestry' do
          expect(child.reload.hide_ancestry_ids).to include parent.id
          expect(child.hide_ancestry_ids).not_to include grandparent.id
        end

        it '#depth_level' do
          expect(child.reload.depth_level).to eq '1'
        end
      end

      context 'not update parent of node' do
        let(:prev_grand_full_anc) { grandparent.hide_ancestry }
        let(:prev_grand_depth_l)  { grandparent.depth_level }

        it '#hide_ancestry' do
          prev_grand_full_anc
          subject

          expect(grandparent.reload.hide_ancestry)
          .to eq prev_grand_full_anc
        end

        it '#depth_level' do
          prev_grand_depth_l
          subject

          expect(grandparent.reload.depth_level).to eq prev_grand_depth_l
        end
      end
    end

    context 'of child update child' do
      before { child.update parent: nil }

      it '#hide_ancestry' do
        expect(child.reload.hide_ancestry).to eq child.id.to_s
        expect(child.hide_ancestry_ids).not_to include parent.id
      end

      it '#depth_level' do
        expect(child.reload.depth_level).to eq '0'
      end
    end
  end
end