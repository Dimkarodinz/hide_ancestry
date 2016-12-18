require 'spec_helper'

describe HideAncestry::ModelManage::CustomAncestryUpdater do
  include_examples 'Monkeys subtree'

  let(:some_monkey) { build :monkey }

  context 'calls in callback' do
    it do
      expect(described_class).to receive(:call).with some_monkey
      some_monkey.save
    end
  end

  describe 'init custom ancestry columns' do
    context '#hide_ancestry' do
      it 'in general case' do
        expect(some_monkey.hide_ancestry).to be_nil
        some_monkey.save

        expect(some_monkey.hide_ancestry)
        .to eq "#{some_monkey.id}"
      end

      it 'if node has #parent' do
        some_monkey.parent = child
        some_monkey.save

        expect(some_monkey.hide_ancestry)
        .to eq(some_monkey.ancestry + "/#{some_monkey.id}")
      end

      it 'if node has #fired_parent' do
        some_monkey.parent = parent
        some_monkey.save
        HideAncestry::ModelManage::Hide.call(parent)

        expect(some_monkey.reload.hide_ancestry)
        .to eq "#{grandparent.id}/#{parent.id}/#{some_monkey.id}"

        expect(some_monkey.ancestry)
        .to eq "#{grandparent.id}"
      end
    end
  end
end