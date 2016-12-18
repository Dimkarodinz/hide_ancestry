shared_examples '.has_hide_ancestry success owner' do |main_model|
  unless main_model.respond_to? :has_hide_ancestry
    before { skip "has_hide_ancestry not included in #{main_model}"}
  end

  describe '.has_hide_ancestry' do
    it 'include EmployeeManageMethods::Errors' do
      expect(main_model.include? HideAncestry::Errors)
      .to be_truthy
    end

    it 'include EmployeeManageMethods::InstanceMethods' do
      expect(main_model.include? HideAncestry::InstanceMethods)
      .to be_truthy
    end

    context 'scopes' do
      subject { main_model }

      it { is_expected.to respond_to :hided }
      it { is_expected.to respond_to :unhided }
      it { is_expected.to respond_to :hided_nodes }
      it { is_expected.to respond_to :hided_childs }
    end
  end
end