shared_examples 'hide_ancestry instance methods owner' do |false_expectation|
  let(:predicate_matcher) { false_expectation.present? ? :not_to : :to }
  
  context do
    subject { described_class.new }
    it { is_expected.public_send predicate_matcher, respond_to(:hide) }
    it { is_expected.public_send predicate_matcher, respond_to(:restore) }
    it { is_expected.public_send predicate_matcher, respond_to(:first_hiding?) }

    it { is_expected.public_send predicate_matcher, respond_to(:hidden?) }
    it { is_expected.public_send predicate_matcher, respond_to(:hide_ancestry_ids) }
    it { is_expected.public_send predicate_matcher, respond_to(:children_of_hidden) }

    it { is_expected.public_send predicate_matcher, respond_to(:hidden_children) }
    it { is_expected.public_send predicate_matcher, respond_to(:hidden_parent_changed?) }
    it { is_expected.public_send predicate_matcher, respond_to(:subtree_with_hidden) }

    it { is_expected.public_send predicate_matcher, respond_to(:hidden_parent) }
    it { is_expected.public_send predicate_matcher, respond_to(:hidden_children_present?) }
    it { is_expected.public_send predicate_matcher, respond_to(:hidden_descendants_ids) }

    it { is_expected.public_send predicate_matcher, respond_to(:hidden_ids) }
    it { is_expected.public_send predicate_matcher, respond_to(:find_first_real_parent) }

  end
end
