require 'spec_helper'

shared_examples 'EmployeeManageMethods owner' do |main_model|
  unless main_model.respond_to? :has_employee_manage_methods
    before { skip "Methods not included in #{main_model}"}
  end

  describe EmployeeManageMethods do
    context '.has_employee_manage_methods' do
      it 'include EmployeeManageMethods::Errors' do
        expect(main_model.include? EmployeeManageMethods::Errors)
        .to be_truthy
      end

      it 'include EmployeeManageMethods::InstanceMethods' do
        expect(main_model.include? EmployeeManageMethods::InstanceMethods)
        .to be_truthy
      end

      context 'scopes' do
        subject { main_model }

        it { is_expected.to respond_to :fired }
        it { is_expected.to respond_to :unfired }
        it { is_expected.to respond_to :fired_users }
        it { is_expected.to respond_to :fired_childs }
      end
    end
  end

  describe EmployeeManageMethods::InstanceMethods do
    # Means that main_model is an User
    unless main_model.eql? User
      before { skip "#{main_model} is not a User"}
    end

    context '#first_firing?' do
      it 'true when prev #old_parent_id was nil' do
        allow(parent).to receive(:previous_changes)
                            .and_return({'old_parent_id' => [nil, 1]})

        expect(parent.first_firing?).to be_truthy
      end

      it 'nil when #old_parent_id no changes' do
        allow(parent).to receive_message_chain('previous_changes.[]')
                            .with('old_parent_id')
                            .and_return(nil)

        expect(parent.first_firing?).to be_nil
      end

      it 'false when prev #old_parent_id not nil' do
        allow(parent).to receive(:previous_changes)
                            .and_return({'old_parent_id' => [1, 2]})
        expect(parent.first_firing?).to eq false
      end
    end

    context '#fired_parent_changed?' do
      subject { child.reload.fired_parent_changed? }

      it 'true if node grandparent != fired parent old parent' do
        EmployeeManage::Fire.call(parent)
        allow(child).to receive(:parent_id).and_return 111
        is_expected.to be_truthy
      end

      it 'false if node grandparent == fired parent old parent' do
        EmployeeManage::Fire.call(parent)
        is_expected.to be_falsey
      end

      it 'false if no fired parent' do
        allow(child).to receive(:fired_parent).and_return nil
        is_expected.to be_falsey
      end
    end

    context '#fired_parent' do
      before { EmployeeManage::Fire.call(grandparent) }

      it 'return record#fired? which ' \
         'includes node#id in #old_child_ids' do
        expect(parent.fired_parent).to eq grandparent
        expect(parent.reload.parent).to be_nil
      end

      it 'return nil if no record#fired? ' \
         'with node#id in #old_child_ids' do
        expect(child.fired_parent).to be_nil
      end
    end

    context '#fired_descendants_ids' do
      before { EmployeeManage::Fire.call(parent) }

      it 'return ids nodes#fired?, ' \
         'which #old_parent_id eql to descendants ids' do

        expect(grandparent.fired_descendants_ids).to include parent.id
        expect(child.fired_descendants_ids).to be_blank
      end
    end

    context '#find_first_real_parent' do
      let(:new_user) { create :user }

      it 'find record by #old_parent_id' do
        EmployeeManage::Fire.call(parent)

        expect(parent.reload.parent).to be_nil
        expect(parent.find_first_real_parent).to eq grandparent
      end

      it 'return #parent if #old_parent_id.nil?' do
        expect(child.find_first_real_parent).to eq parent
        expect(grandparent.find_first_real_parent).to be_nil
      end

      it 'call itself to finded if record#fired?' do
        EmployeeManage::Fire.call(parent)
        EmployeeManage::Fire.call(child)
        expect(child.find_first_real_parent).to eq grandparent
      end
    end
  end
end