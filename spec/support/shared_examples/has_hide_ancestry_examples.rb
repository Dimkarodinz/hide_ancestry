shared_examples '.has_hide_ancestry success owner' do
  unless described_class.respond_to? :has_hide_ancestry
    before { skip "has_hide_ancestry not included in #{described_class}"}
  end

  describe '.has_hide_ancestry' do
    it 'include EmployeeManageMethods::Errors' do
      expect(described_class.include? HideAncestry::Errors)
      .to be_truthy
    end

    it 'include EmployeeManageMethods::InstanceMethods' do
      expect(described_class.include? HideAncestry::InstanceMethods)
      .to be_truthy
    end

    context 'scopes' do
      subject { described_class }

      it { is_expected.to respond_to :hided }
      it { is_expected.to respond_to :unhided }
      it { is_expected.to respond_to :hided_nodes }
      it { is_expected.to respond_to :hided_childs }
    end
  end
end