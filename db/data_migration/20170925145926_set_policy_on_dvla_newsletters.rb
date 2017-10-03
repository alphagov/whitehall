# Some publications* are missing a Policy/Topic.
# This means the document is invalid. When the user tries to unwithdraw
# the Publication, it fails because of the validation checks and the
# user is unable to edit that document.
# Zendesk https://govuk.zendesk.com/agent/tickets/2406623

editions = []
editions << Publication.find(208031) # https://www.gov.uk/government/publications/mns-news-february-2013
editions << Publication.find(213038) # https://www.gov.uk/government/publications/mns-news-march-2013
editions << Publication.find(208034) # https://www.gov.uk/government/publications/mns-news-april-2013
editions << Publication.find(213041) # https://www.gov.uk/government/publications/mns-news-may-2013
editions << Publication.find(254050) # https://www.gov.uk/government/publications/mns-news-september-2013
editions << Publication.find(254051) # https://www.gov.uk/government/publications/mns-news-october-2013
editions << Publication.find(204728) # https://www.gov.uk/government/publications/newsdvla-issue-4
editions << Publication.find(245744) # https://www.gov.uk/government/publications/newsdvla-issue-5

editions.each do |edition|
  if edition
    transport = Topic.find_by(name: "Transport")
    edition.topics << transport if edition.topics.empty?
  end
end
