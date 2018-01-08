require "policy_admin_url_replacer"

puts "Building ID/slug to URL mapping"

policies_and_supporting_pages = Edition.unscoped.where(type: %w[Policy SupportingPage])

id_to_url_mapping = policies_and_supporting_pages.inject({}) { |hash, edition|
  url = Whitehall.url_maker.public_document_url(edition, {}, include_deleted_documents: true)

  id = edition.id.to_s
  slug = edition.slug

  edition = nil

  hash.merge(
    id => url,
    slug => url,
  )
}

edition_ids = Edition.where(state: Edition::PUBLICLY_VISIBLE_STATES + Edition::PRE_PUBLICATION_STATES).pluck(:id)

edition_ids.each_slice(1000).with_index do |ids, index|
  puts "Starting batch #{index}"

  pid = fork do
    PolicyAdminURLReplacer.new(id_to_url_mapping).replace_in!(Edition.where(id: ids))
  end

  Process.wait(pid)
end
