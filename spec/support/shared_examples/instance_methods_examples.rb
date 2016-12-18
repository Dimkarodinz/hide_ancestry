shared_examples 'hide_ancestry instance methods owner' do |main_model|
  context do
    subject { main_model.new }

    it { is_expected.to respond_to :hide }
    it { is_expected.to respond_to :restore }
    it { is_expected.to respond_to :first_hiding? }

    it { is_expected.to respond_to :hided? }
    it { is_expected.to respond_to :hide_ancestry_ids }
    it { is_expected.to respond_to :children_of_hided }

    it { is_expected.to respond_to :hided_children }
    it { is_expected.to respond_to :hided_parent_changed? }
    it { is_expected.to respond_to :subtree_with_hided }

    it { is_expected.to respond_to :hided_parent }
    it { is_expected.to respond_to :hided_children_present? }
    it { is_expected.to respond_to :hided_descendants_ids }

    it { is_expected.to respond_to :hided_ids }
    it { is_expected.to respond_to :find_first_real_parent }
  end
end
