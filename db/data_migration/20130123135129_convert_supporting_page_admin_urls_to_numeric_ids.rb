OLD_ADMIN_LINK_REGEX = %r{/government/admin/editions/([^/]+)/supporting-pages/([\w-]+)}
Edition.where("state <> 'archived'").find_each do |edition|
  next unless edition.body.match(OLD_ADMIN_LINK_REGEX)
  edition.body.dup.scan(OLD_ADMIN_LINK_REGEX) do |match|
    edition_id, slug = match
    next if slug =~ /^[0-9]+$/
    page = SupportingPage.find_by_slug_and_edition_id(slug, edition_id)
    if page.nil?
      puts "Edition #{edition.id}: Cannot find supporting page '#{slug}'"
      next
    end
    edition.body.gsub!(%r{/government/admin/editions/#{edition_id}/supporting-pages/#{slug}},
                       "/government/admin/editions/#{edition_id}/supporting-pages/#{page.id.to_s}")
  end
  edition.update_column(:body, edition.body)
end
