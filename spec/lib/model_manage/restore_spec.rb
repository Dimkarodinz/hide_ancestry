require 'spec_helper'

describe HideAncestry::ModelManage::Restore do
  include_examples 'Monkeys subtree'

  context '#call' do
    describe do
      subject { described_class.new(parent) }
      after   { subject.call }

      it { is_expected.to receive :restore_parent }
      it { is_expected.to receive :restore_children }

      it do
        is_expected.to receive(:change_hided_status).with false
      end
    end
 
    context 'restore parent from #find_first_real_parent' do
      it 'if #parent_id is nil' do
        child.update_attribute :parent_id, nil
        allow(child).to receive(:find_first_real_parent).and_return grandparent
        described_class.call(child)

        expect(child.reload.parent_id).to eq grandparent.id
      end

      it 'unless #parent_id is nil' do
        allow(child).to receive(:find_first_real_parent).and_return grandparent
        described_class.call(child)
        expect(child.reload.parent_id).to eq parent.id
      end
    end

    context 'restore children' do
      it 'doesn`t restore hided children' do
        allow(child).to receive(:hided?).and_return true
        described_class.call(grandparent)
        expect(grandparent.reload.child_ids).not_to include child.id
      end

      describe do
        before { HideAncestry::ModelManage::Hide.call(parent) }

        it 'successfully' do
          described_class.call(parent)
          expect(parent.child_ids).to include child.id
        end

        it 'doesn`t try to restore vanished children' do
          vanished_id = child.id
          child.destroy
          described_class.call(parent)
          expect(parent.child_ids).not_to include vanished_id
        end

        it 'doesn`t restore children who changed parent' do
          child.update_attribute :parent, nil
          described_class.call(parent)
          expect(child.parent).not_to eq parent
        end
      end
    end

    context 'change #hided_status' do
      before { parent.update_attribute :hided_status, true }

      it 'to false' do
        described_class.call(parent)
        expect(parent.hided_status).to be_falsey
      end
    end

    context 'parent hide, then substructure has new parent' do
      let(:new_root_monkey) { create :monkey }

      before do
        HideAncestry::ModelManage::Hide.call(parent)
        grandparent.update parent: new_root_monkey
      end

      it 'do not updates #hide_ancestry subtree' do
        expect(child.reload.hide_ancestry_ids).to include parent.id
        expect(child.hide_ancestry_ids).to include new_root_monkey.id
      end

      it 'restores parent correctly' do
        described_class.call(parent)
        expect(parent.reload.children).to include child
        expect(parent.reload.parent).to eq grandparent
        expect(new_root_monkey.reload.children).to include grandparent
      end

      it 'new substructure is correct' do
        described_class.call(parent)
        expect(new_root_monkey.descendants.pluck(:id))
        .to eq [grandparent.id, parent.id, child.id]
      end
    end

    context 'restoring' do
      let(:root_monkey) { create :monkey }

      before do
        grandparent.update parent: root_monkey
        HideAncestry::ModelManage::Hide.call(parent)
        HideAncestry::ModelManage::Hide.call(grandparent)
      end

      it 'parent' do
        described_class.call(parent)
        expect(root_monkey.reload.children.pluck(:id)).to include parent.id
        expect(parent.reload.children.pluck(:id)).to include child.id
      end

      it 'grandparent' do
        described_class.call(grandparent)
        expect(root_monkey.reload.children.pluck(:id)).to include grandparent.id
        expect(grandparent.reload.children.pluck(:id)).to include child.id
      end

      context 'both monkeys' do
        after do
          expect(grandparent.reload.parent).to eq root_monkey
          expect(parent.reload.parent).to eq grandparent
          expect(child.reload.parent).to eq parent

          expect(root_monkey.reload.children).to include grandparent
          expect(root_monkey.children).not_to include parent
        end

        it 'in natural order' do
          described_class.call(grandparent)
          described_class.call(parent)
        end

        it 'in reverse order' do
          described_class.call(parent)
          described_class.call(grandparent)
        end
      end
    end
  end
end
