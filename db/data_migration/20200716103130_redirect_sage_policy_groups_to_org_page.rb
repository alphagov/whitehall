SLUGS = %w[
  scientific-advisory-group-for-emergencies-sage
  scientific-advisory-group-for-emergencies-sage-coronavirus-covid-19-response
].freeze

REDIRECT_PATH = "/government/organisations/scientific-advisory-group-for-emergencies".freeze

SLUGS.each do |slug|
  group = PolicyGroup.find_by(slug:)
  unless group
    puts "could not find #{slug}"
    next
  end

  content_id = group.content_id
  group.delete
  PublishingApiRedirectWorker.new.perform(content_id, REDIRECT_PATH, "en")

  puts "#{slug} -> #{REDIRECT_PATH}"
end
