require 'gds_api/router'

router = GdsApi::Router.new(Plek.find('router-api'))

document_publications_urls = [
  %w(applying-for-a-uk-visa-in-japan apply-for-a-uk-visa-in-japan),
  %w(argentina-apply-for-a-uk-visa apply-for-a-uk-visa-in-argentina),
  %w(bankruptcy-what-will-happen-to-my-pension bankruptcy-pension),
  %w(can-my-bankruptcy-be-cancelled cancel-bankruptcy-order),
  %w(chile-apply-for-a-uk-visa apply-for-a-uk-visa-in-chile),
  %w(dealing-with-debt-how-to-make-someone-bankrupt apply-to-make-someone-bankrupt),
  %w(kuwait-apply-for-a-uk-visa apply-for-a-uk-visa-in-kuwait),
  %w(russia-apply-for-a-uk-visa apply-for-a-uk-visa-in-russia),
  %w(saudi-arabia-apply-for-a-uk-visa apply-for-a-uk-visa-in-saudi-arabia),
  %w(what-will-happen-to-my-home bankruptcy-your-home)
]

document_collections_urls = [
  %w(chapter-6-businessmen-and-investors-immigration-directorate-instructions chapter-06-businessmen-and-investors-immigration-directorate-instructions)
]

document_publications_urls.each do |old_slug, new_slug|
  changeling = Document.find_by(slug: old_slug)
  if changeling
    puts "Changing document slug #{old_slug} -> #{new_slug}"
    changeling.update_attribute(:slug, new_slug)
    router.add_redirect_route("/government/publications/#{old_slug}",
                              'exact',
                              "/government/publications/#{new_slug}")
  else
    puts "Can't find document with slug of #{old_slug} - skipping"
  end
end


document_collections_urls.each do |old_slug, new_slug|
  changeling = Document.find_by(slug: old_slug)
  if changeling
    puts "Changing document slug #{old_slug} -> #{new_slug}"
    changeling.update_attribute(:slug, new_slug)
    router.add_redirect_route("/government/collections/#{old_slug}",
                              'exact',
                              "/government/collections/#{new_slug}")
  else
    puts "Can't find document with slug of #{old_slug} - skipping"
  end
end
