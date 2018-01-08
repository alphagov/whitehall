dodgy_slugs = %w{
  progress-check-at-age-2-and-eyfs-profile
  2-year-old-early-education-entitlement-local-authority-guide
  a-year-until-first-working-parents-receive-doubled-free-childcare
  early-years-pupil-premium-guide-for-local-authorities
  local-authority-moderation-of-the-eyfs-profile
  key-stage-2-tests-how-to-apply-for-special-consideration
  pshe-and-sre-in-schools-government-response
  gcse-results-show-surge-in-pupils-taking-valuable-stem-subjects
  phonics-screening-check-how-to-administer-the-check
}

dodgy_slugs.each do |slug|
  puts "Republishing #{slug}"
  Whitehall::PublishingApi.republish_async(Document.where(slug: slug).first.published_edition)
end
