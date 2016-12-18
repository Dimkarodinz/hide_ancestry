module SharedExamples
  shared_examples 'Monkeys subtree' do
    let!(:grandparent) { create :monkey }
    let!(:parent) { create :monkey, parent: grandparent }
    let!(:child)  { create :monkey, parent: parent }
  end

  shared_examples 'successfully restored nodes' do
    it do
      expect(grandparent.hide_ancestry).to eq grand_prev_anc_path
    end

    it do
      expect(grandparent.depth_level).to eq grand_prev_depth_l
    end

    it do
      expect(parent.hide_ancestry).to eq parent_prev_anc_path
    end

    it do
      expect(parent.depth_level).to eq parent_prev_depth_l
    end

    it do
      expect(parent.reload.parent_id).to eq parent_prev_parent_id
    end

    it do
      expect(grandparent.reload.parent_id).to eq grandparent_prev_parent_id
    end
  end
end