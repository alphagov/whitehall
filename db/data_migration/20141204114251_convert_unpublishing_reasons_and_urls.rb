# first fix redirects to whitehall-admin URLs
Unpublishing.where('alternative_url like "https://whitehall-admin%"').each do |unp|
  original_url = unp.alternative_url
  new_url = nil
  # for items that point to an admin show page, find the public url of that edition
  original_url.match('government/admin/[\w-]+/(\d+)$') do |m|
    # linked edition can be deleted, nothing we can do about that.
    edition = Edition.unscoped.find(m[1])
    new_url = Whitehall.url_maker.public_document_url(edition)
  end

  # otherwise it's a frontend URL, just substitute gov.uk
  if new_url.nil?
    new_url = original_url.sub("https://whitehall-admin.production.alphagov.co.uk", Whitehall.public_root)
  end

  @logger.info "Fixing unpublishing id #{unp.id}: #{original_url} => #{new_url}"
  unp.update_column(:alternative_url, new_url)
end

# Fix any alternative urls that have stray whitespace
Unpublishing.where("alternative_url LIKE ' %'").each do |unpubishing|
  unpubishing.update_column(:alternative_url, unpubishing.alternative_url.strip)
end

# Now fix deprecated unpublishing reasons. If they currently (after above fix)
# redirect to a page on gov.uk, keep that redirect with reason 4 (consolidated
# into another page), otherwise turn off redirect and use reason 1 (published in
# error).
Unpublishing.where(unpublishing_reason_id: [2, 3]).each do |unp|
  url = unp.alternative_url
  redirect = unp.redirect

  if redirect
    if url.present? && url.match(Whitehall.public_root)
      unp.unpublishing_reason_id = 4
    else
      unp.redirect = false
      unp.unpublishing_reason_id = 1
    end
  else
    unp.unpublishing_reason_id = 1
  end

  @logger.info "Fixing unpublishing id #{unp.id}: reason #{unp.unpublishing_reason_id}, redirect #{unp.redirect}"
  # Again, need to skip validations because edition can be deleted.
  unp.save(validate: false)
end
