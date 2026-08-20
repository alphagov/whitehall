db = ActiveRecord::Base.connection

id_list = ->(ids) { ids.any? ? ids.map(&:to_i).join(",") : "NULL" }

delete_from = lambda do |table, where|
  count = db.select_value("SELECT COUNT(*) FROM #{table} WHERE #{where}").to_i
  next if count.zero?

  db.execute("DELETE FROM #{table} WHERE #{where}")
  puts "  #{table}: deleted #{count}"
end

document_ids = db.select_values(<<~SQL)
  SELECT DISTINCT d.id
  FROM documents d
  LEFT JOIN editions e ON e.document_id = d.id
  WHERE d.document_type = 'PlanForChangeLandingPage'
     OR e.type = 'PlanForChangeLandingPage'
SQL

puts document_ids.any? ? "Found #{document_ids.size} documents for deletion" : "No Plan for Change landing page documents found for deletion"

document_ids.each do |document_id|
  edition_ids = db.select_values("SELECT id FROM editions WHERE document_id = #{document_id}")

  puts "Processing document #{document_id} (#{edition_ids.size} editions)"

  edition_ids.each do |edition_id|
    puts "Processing edition #{edition_id}"

    image_data_ids = db.select_values("SELECT DISTINCT image_data_id FROM images WHERE edition_id = #{edition_id} AND image_data_id IS NOT NULL")
    attachment_data_ids = db.select_values("SELECT DISTINCT attachment_data_id FROM attachments WHERE attachable_type = 'Edition' AND attachable_id = #{edition_id} AND attachment_data_id IS NOT NULL")

    delete_from.call("attachment_sources", "attachment_id IN (SELECT id FROM attachments WHERE attachable_type = 'Edition' AND attachable_id = #{edition_id})")
    delete_from.call("images", "edition_id = #{edition_id}")
    delete_from.call("attachments", "attachable_type = 'Edition' AND attachable_id = #{edition_id}")

    orphaned_image_data = db.select_values(<<~SQL)
      SELECT id FROM image_data
      WHERE id IN (#{id_list.call(image_data_ids)})
        AND NOT EXISTS (SELECT 1 FROM images WHERE images.image_data_id = image_data.id)
    SQL

    orphaned_attachment_data = db.select_values(<<~SQL)
      SELECT id FROM attachment_data
      WHERE id IN (#{id_list.call(attachment_data_ids)})
        AND NOT EXISTS (SELECT 1 FROM attachments WHERE attachments.attachment_data_id = attachment_data.id)
    SQL

    delete_from.call("assets", "assetable_type = 'ImageData' AND assetable_id IN (#{id_list.call(orphaned_image_data)})")
    delete_from.call("image_data", "id IN (#{id_list.call(orphaned_image_data)})")
    delete_from.call("assets", "assetable_type = 'AttachmentData' AND assetable_id IN (#{id_list.call(orphaned_attachment_data)})")
    delete_from.call("attachment_data", "id IN (#{id_list.call(orphaned_attachment_data)})")

    delete_from.call(
      "link_checker_api_report_links",
      "link_checker_api_report_id IN (SELECT id FROM link_checker_api_reports WHERE edition_id = #{edition_id})",
    )

    delete_from.call("edition_dependencies", "dependable_type = 'Edition' AND dependable_id = #{edition_id}")

    %w[
      access_limiting_individuals
      access_limiting_organisations
      edition_authors
      edition_dependencies
      edition_organisations
      edition_translations
      edition_world_locations
      editorial_remarks
      link_checker_api_reports
      recent_edition_openings
      related_mainstreams
      topical_event_featurings
      unpublishings
      worldwide_offices
    ].each { |table| delete_from.call(table, "edition_id = #{edition_id}") }

    delete_from.call("versions", "item_type IN ('Edition', 'PlanForChangeLandingPage', 'LandingPage') AND item_id = #{edition_id}")
    delete_from.call("editions", "id = #{edition_id}")
  end

  %w[
    document_collection_group_memberships
    edition_links
    features
    review_reminders
  ].each { |table| delete_from.call(table, "document_id = #{document_id}") }

  delete_from.call("versions", "item_type = 'Document' AND item_id = #{document_id}")
  delete_from.call("documents", "id = #{document_id}")
end
