require 'spec_helper'

describe EmployeeManage::CustomAncestryUpdater do
  include_examples '.user factories'

  let(:some_user) { build :user }

  context 'calls in callback' do
    it do
      expect(described_class).to receive(:call).with some_user
      some_user.save
    end

    it '#update_custom_ancestry_cols' do
      allow(described_class).to(receive(:call)
                                .with(some_user)
                                .and_return described_class)

      expect(some_user.send :update_custom_ancestry_cols)
      .to eq described_class
    end

    it '#after_save' do
      expect(some_user)
      .to callback(:update_custom_ancestry_cols)
      .after(:save)
    end
  end

  describe 'init custom ancestry columns' do
    context '#full_ancestry_path' do
      it 'in general case' do
        expect(some_user.full_ancestry_path).to be_nil
        some_user.save

        expect(some_user.full_ancestry_path)
        .to eq "#{some_user.id}"
      end

      it 'if node has #parent' do
        some_user.parent = child
        some_user.save

        expect(some_user.full_ancestry_path)
        .to eq(some_user.ancestry + "/#{some_user.id}")
      end

      it 'if node has #fired_parent' do
        some_user.parent = parent
        some_user.save
        EmployeeManage::Fire.call(parent)

        expect(some_user.reload.full_ancestry_path)
        .to eq "#{grandparent.id}/#{parent.id}/#{some_user.id}"

        expect(some_user.ancestry)
        .to eq "#{grandparent.id}"
      end
    end

    context '#depth_level' do
      it 'in general case' do
        expect(some_user.depth_level).to be_nil
        some_user.save

        expect(some_user.depth_level).to eq '0'
        expect(some_user.depth).to eq 0
      end

      it 'if node has #depth' do
        allow(some_user).to receive(:depth).and_return 4
        some_user.save
        expect(some_user.depth_level).to eq '1.2.3.4'
      end

      it 'if node has #fired_parent' do
        some_user.parent = parent
        some_user.save
        EmployeeManage::Fire.call(parent)

        # because #parent becames grandparent;
        # fired parent has no #ancestry
        expect(some_user.reload.depth).to eq 1

        # if parent was present as an #parent
        expect(some_user.depth_level).to eq '1.2'
      end
    end
  end
end