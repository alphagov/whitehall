module Admin::EditionTagsHelper
  def checkbox_for_taxonomy(selected_taxon_content_ids, taxon)
    checked = taxon.taxon_list.any? do |descendant_taxon|
      selected_taxon_content_ids.include?(descendant_taxon.content_id)
    end

    check_box_tag(
      "taxonomy_tag_form[taxons][]",
      taxon.content_id,
      checked,
      id: taxon.content_id,
      "data-taxon-name" => taxon.name,
      "data-parent-content-id" => taxon.parent_node.try(:content_id),
      "data-ancestors": taxon.breadcrumb_trail.map(&:name).join('|')
    )
  end
end
