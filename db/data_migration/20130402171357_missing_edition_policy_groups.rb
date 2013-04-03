puts "EditionPolicyGroups: #{EditionPolicyGroup.all.count}"

epg = EditionPolicyGroup.all.group_by {|x| Edition.unscoped.find_by_id(x.edition_id).document_id }
documents = Document.find(epg.keys).select(&:published?)

documents.each do |doc|
  ids = doc.editions.map(&:id)
  policy_groups_by_edition = doc.editions.map(&:edition_policy_groups)

  policy_group_ids = policy_groups_by_edition.reject(&:blank?).last.map(&:policy_group_id)
  ids_at_index_to_update = []
  policy_groups_by_edition.each_with_index {|epg, i| ids_at_index_to_update << i if epg.blank? }

  edition_ids_to_update = ids_at_index_to_update.map { |i| ids[i] }

  edition_ids_to_update.each do |e_id|
    policy_group_ids.each do |pg_id|
      EditionPolicyGroup.create edition_id: e_id, policy_group_id: pg_id
    end
  end
end
puts "After update..."
puts "EditionPolicyGroups: #{EditionPolicyGroup.all.count}"