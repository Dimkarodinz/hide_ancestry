shared_examples 'successfully restored nodes' do
  it { expect(grandparent.hide_ancestry).to eq grand_prev_anc_path }
  it { expect(parent.hide_ancestry).to eq parent_prev_anc_path }

  it { expect(parent.reload.parent_id).to eq parent_prev_parent_id }
  it { expect(grandparent.reload.parent_id).to eq grandparent_prev_parent_id }
end