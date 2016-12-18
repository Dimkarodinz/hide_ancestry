shared_examples 'Monkeys subtree' do
  let!(:grandparent) { create :monkey }
  let!(:parent) { create :monkey, parent: grandparent }
  let!(:child)  { create :monkey, parent: parent }
end
