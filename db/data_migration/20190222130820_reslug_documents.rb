puts "Reslugging documents..."

documents = [
  {
    slug: "letter-to-providers-on-health-and-safety",
    new_slug: "letters-from-the-regulator-of-social-housing-grenfell",
  },
  {
    slug: "decision-instrument-16-revision-to-the-value-for-money-standard-and-introduction-of-an-associated-code-of-practice",
    new_slug: "decision-instruments-2015-to-2018",
  },
  {
    slug: "decision-statement-on-the-value-for-money-standard",
    new_slug: "decision-statements-2014-to-2018",
  },
  {
    slug: "innovation-plan-hca-regulator-of-social-housing",
    new_slug: "innovation-plan-regulator-of-social-housing",
  },
  {
    slug: "regulation-committee-minutes-july-2018",
    new_slug: "regulation-committee-minutes-2018",
  },
  {
    slug: "regulation-committee-minutes-november-2017",
    new_slug: "regulation-committee-minutes-2017",
  },
  {
    slug: "regulation-committee-minutes-december-2016",
    new_slug: "regulation-committee-minutes-2016",
  },
  {
    slug: "regulation-committee-minutes-14-december-2015",
    new_slug: "regulation-committee-minutes-2015",
  },
  {
    slug: "regulation-committee-minutes-23-november-2015",
    new_slug: "regulation-committee-minutes-2014",
  },
]

documents.each do |document|
  doc = Document.find_by(slug: document[:slug])
  unless doc.present?
    puts "Document #{document[:slug]} not found!"
    next
  end

  # remove the most recent edition from the search index
  edition = doc.editions.published.last
  Whitehall::SearchIndex.delete(edition)

  # change the slug of the document and create a redirect from the original
  doc.update_attributes(sluggable_string: document[:new_slug])
  PublishingApiDocumentRepublishingWorker.new.perform(doc.id)
end
