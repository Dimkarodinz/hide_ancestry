require 'spec_helper'

describe EmployeeManage::Restore do
  include_examples '.user factories'

  context '#call' do
    describe do
      subject { described_class.new(parent) }
      after   { subject.call }

      it { is_expected.to receive :restore_parent }
      it { is_expected.to receive :restore_children }

      it do
        is_expected.to receive(:change_fired_status).with false
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
      it 'doesn`t restore fired children' do
        allow(child).to receive(:fired?).and_return true
        described_class.call(grandparent)
        expect(grandparent.reload.child_ids).not_to include child.id
      end

      describe do
        before { EmployeeManage::Fire.call(parent) }

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

    context 'change #fired_status' do
      before { parent.update_attribute :fired_status, true }

      it 'to false' do
        described_class.call(parent)
        expect(parent.fired_status).to be_falsey
      end
    end

    context 'parent fire, then substructure has new parent' do
      let(:new_root_user) { create :user }

      before do
        EmployeeManage::Fire.call(parent)
        grandparent.update parent: new_root_user
      end

      it 'do not updates #full_ancestry_path subtree' do
        expect(child.reload.old_path_ids).to include parent.id
        expect(child.old_path_ids).to include new_root_user.id
      end

      it 'restores parent correctly' do
        EmployeeManage::Restore.call(parent)
        expect(parent.reload.children).to include child
        expect(parent.reload.parent).to eq grandparent
        expect(new_root_user.reload.children).to include grandparent
      end

      it 'new substructure is correct' do
        EmployeeManage::Restore.call(parent)
        expect(new_root_user.descendants.pluck(:id))
        .to eq [grandparent.id, parent.id, child.id]
      end
    end

    context 'restoring' do
      let(:root_user) { create :user }

      before do
        grandparent.update parent: root_user
        EmployeeManage::Fire.call(parent)
        EmployeeManage::Fire.call(grandparent)
      end

      it 'parent' do
        EmployeeManage::Restore.call(parent)
        expect(root_user.reload.children.pluck(:id)).to include parent.id
        expect(parent.reload.children.pluck(:id)).to include child.id
      end

      it 'grandparent' do
        EmployeeManage::Restore.call(grandparent)
        expect(root_user.reload.children.pluck(:id)).to include grandparent.id
        expect(grandparent.reload.children.pluck(:id)).to include child.id
      end

      context 'both users' do
        after do
          expect(grandparent.reload.parent).to eq root_user
          expect(parent.reload.parent).to eq grandparent
          expect(child.reload.parent).to eq parent

          expect(root_user.reload.children).to include grandparent
          expect(root_user.children).not_to include parent
        end

        it 'in natural order' do
          EmployeeManage::Restore.call(grandparent)
          EmployeeManage::Restore.call(parent)
        end

        it 'in reverse order' do
          EmployeeManage::Restore.call(parent)
          EmployeeManage::Restore.call(grandparent)
        end
      end
    end
  end
end

# to concern testing
    # context '#fired_ancestors_ids' do
    #   let(:custom_fired) { create :user, fired_status: true }

    #   subject { child.fired_ancestors_ids }

    #   it { is_expected.to be_a Array }
    #   it { is_expected.to be_blank }

    #   context do
    #     before do
    #       parent.do_fired!
    #       child.reload
    #     end

    #     it 'returns ids of self ancestor#fired_status' do
    #       is_expected.to include parent.id
    #     end

    #     it 'doesn`t returns other fired users ids' do
    #       custom_fired.touch
    #       is_expected.not_to include custom_fired.id
    #     end
    #   end
    # end

    # context '#old_path_ids' do
    #   it 'is an array' do
    #     expect(parent.old_path_ids).to be_a Array
    #   end

    #   it 'returns #full_ancestry_path without last element' do
    #     allow(parent).to receive(:full_ancestry_path).and_return('1/2')
    #     expect(parent.old_path_ids).to eq [1]
    #   end

    #   it 'elements should be integers' do
    #     allow(parent).to receive(:full_ancestry_path).and_return('1/3')
    #     expect(parent.old_path_ids.first).to be_a Integer
    #   end

    #   it 'returns blank array if path too short' do
    #     allow(parent).to receive(:full_ancestry_path).and_return('1')
    #     expect(parent.old_path_ids).to be_blank
    #   end
    # end

    # context '#fired_parent_changed?' do
    #   subject { parent.fired_parent_changed? }

    #   it { is_expected.to be_in [true, false] }

    #   it 'return false if no fired parent' do
    #     allow(parent).to receive(:fired_parent).and_return(nil)
    #     is_expected.to be_falsey
    #   end

    #   describe 'check for contrasts between real parent and parent of fired' do
    #     it 'if equal' do
    #       allow(parent).to receive(:parent_id).and_return(grandparent.id)
    #       allow(parent)
    #       .to receive_message_chain('fired_parent.find_first_real_parent')
    #           .and_return(grandparent)

    #       is_expected.to be_falsey
    #     end

    #     it 'if not equal' do
    #       allow(parent).to receive(:parent_id).and_return(grandparent.id + 1)
    #       allow(parent)
    #       .to receive_message_chain('fired_parent.find_first_real_parent')
    #           .and_return(grandparent)

    #       is_expected.to be_truthy
    #     end
    #   end
    # end

    # describe '#save_child_ids' do
    #   let(:parent_second) { create :user, parent_id: grandparent.id }
    #   let(:parent_second_child) { create :user, parent_id: parent_second.id }

    #   subject { grandparent.save_child_ids }

    #   it 'save existing childs' do
    #     subject
    #     expect(grandparent.old_child_ids).to eq grandparent.children.pluck(:id)
    #   end

    #   it 'save fired childs' do
    #     parent_second.do_fired!
    #     subject
    #     expect(grandparent.old_child_ids)
    #     .to eq (grandparent.children.pluck(:id) << parent_second.id)
    #   end

    #   it 'save chilren ids to #old_child_ids' do
    #     expect(grandparent).to receive(:save)
    #     subject
    #   end
    # end

    # context '#find_first_real_parent' do
    #   subject { parent.find_first_real_parent }

    #   it 'return regular parent if no #old_parent_id' do
    #     allow(parent).to receive(:old_parent_id).and_return nil
    #     is_expected.to eq grandparent
    #   end

    #   it 'look for parent from #old_parent_id' do
    #     allow(parent).to receive(:old_parent_id).and_return 13
    #     expect(described_class)
    #     .to receive(:find_by)
    #         .with(id: parent.old_parent_id)
    #     subject
    #   end

    #   it 'return #parent if no parent from #old_parent_id' do
    #     allow(parent).to receive(:old_parent_id).and_return true
    #     allow(described_class)
    #     .to receive(:find_by)
    #         .and_return nil
    #     is_expected.to eq grandparent
    #   end

    #   it 'check if finded users #fired?' do
    #     allow(parent).to receive(:old_parent_id).and_return true
    #     allow(described_class).to receive(:find_by).and_return grandparent
    #     expect(grandparent).to receive(:fired?)
    #     subject
    #   end

    #   context 'finded_usr#fired?' do
    #     it 'if true, call itself to finded parent' do
    #       allow(parent).to receive(:old_parent_id).and_return true
    #       allow(described_class).to receive(:find_by).and_return grandparent

    #       allow(grandparent).to receive(:fired?).and_return(true)
    #       expect(grandparent).to receive(:find_first_real_parent)
    #       subject
    #     end

    #     it 'if false, calls finded parent' do
    #       allow(parent).to receive(:old_parent_id).and_return true
    #       allow(described_class).to receive(:find_by).and_return grandparent

    #       allow(grandparent).to receive(:fired?).and_return false
    #       is_expected.to eq grandparent
    #     end
    #   end
    # end