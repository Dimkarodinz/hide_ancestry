shared_examples '.has_hide_ancestry owner' do |false_expectation|
  let(:predicate_matcher) { false_expectation.present? ? :not_to : :to }

  describe '.has_hide_ancestry' do
    it 'include EmployeeManageMethods::Errors' do
      expect(described_class.include? HideAncestry::Validators)
      .public_send predicate_matcher, be_truthy
    end

    it 'include EmployeeManageMethods::InstanceMethods' do
      expect(described_class.include? HideAncestry::InstanceMethods)
      .public_send predicate_matcher, be_truthy
    end

    context 'scopes' do
      subject { described_class }

      it { is_expected.public_send predicate_matcher, respond_to(:hidden) }
      it { is_expected.public_send predicate_matcher, respond_to(:unhidden) }
      it { is_expected.public_send predicate_matcher, respond_to(:hidden_nodes) }
      it { is_expected.public_send predicate_matcher, respond_to(:hidden_childs) }
    end
  end
end