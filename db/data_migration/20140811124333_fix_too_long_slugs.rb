require 'gds_api/router'

router = GdsApi::Router.new(Plek.find('router-api'))

updated = false

Document.find_by_sql("SELECT *, LENGTH(slug) AS slug_length FROM documents HAVING `slug_length` > 250;").each do |document|
  if (published = document.published_edition)
    old_slug = document.slug
    old_path = Whitehall.url_maker.document_path(published)
    new_slug = document.normalize_friendly_id(published.title)
    puts "Changing '#{old_slug}' to '#{new_slug}' for document '#{document.id}'"
    document.update_attribute(:slug, new_slug)
    new_path = Whitehall.url_maker.document_path(published.reload)
    puts "Redirecting '#{old_path}' to '#{new_path}'"
    router.add_redirect_route(old_path, 'exact', new_path)
    updated = true
  end
end

router.commit_routes if updated
