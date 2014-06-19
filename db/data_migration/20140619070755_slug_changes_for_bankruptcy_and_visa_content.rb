document_urls = [
  %w(applying-for-a-uk-visa-in-japan apply-for-a-uk-visa-in-japan),
  %w(argentina-apply-for-a-uk-visa apply-for-a-uk-visa-in-argentina),
  %w(bankruptcy-what-will-happen-to-my-pension bankruptcy-pension),
  %w(can-my-bankruptcy-be-cancelled cancel-bankruptcy-order),
  %w(chapter-6-businessmen-and-investors-immigration-directorate-instructions chapter-06-businessmen-and-investors-immigration-directorate-instructions),
  %w(chile-apply-for-a-uk-visa apply-for-a-uk-visa-in-chile),
  %w(dealing-with-debt-how-to-make-someone-bankrupt apply-to-make-someone-bankrupt),
  %w(kuwait-apply-for-a-uk-visa apply-for-a-uk-visa-in-kuwait),
  %w(russia-apply-for-a-uk-visa apply-for-a-uk-visa-in-russia),
  %w(saudi-arabia-apply-for-a-uk-visa apply-for-a-uk-visa-in-saudi-arabia),
  %w(what-will-happen-to-my-home bankruptcy-your-home)
]

document_urls.each do |old_slug, new_slug|
  changeling = Document.find_by_slug(old_slug)
  if changeling
    puts "Changing document slug #{old_slug} -> #{new_slug}"
    changeling.update_attribute(:slug, new_slug)
  else
    puts "Can't find document with slug of #{old_slug} - skipping"
  end
end
