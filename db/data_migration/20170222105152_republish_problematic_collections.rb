slugs = [
  "ad-hoc-statistical-analysis-2015-quarter-1",
  "cde-marketplace-5-february-2015-exhibitor-case-studies",
  "chapter-32-port-cases-involving-prosecution-immigration-directorate-instructions",
  "command-papers",
  "departmental-exceptions-to-spending-controls-2014",
  "electronic-business-commissioners-directions",
  "flagging-up-newsletters",
  "green-deal-quick-guides",
  "greenhouse-gas-conversion-factors-for-company-reporting",
  "guidance-on-british-citizenship",
  "house-of-commons-papers",
  "ministerial-gifts-hospitality-travel-and-meetings-2012",
  "ministerial-gifts-hospitality-travel-and-meetings-2013",
  "national-curriculum-assessments-2013",
  "official-documents",
  "oisc-news",
  "self-assessment-helpsheets-additional-information",
  "social-care-online-questionnaires-2015",
  "think-act-report-sign-ups-and-case-studies"
]

Document.where(slug: slugs, document_type: "Collection").each do |doc|
  puts "Republishing Document ##{doc.slug}..."
  PublishingApiDocumentRepublishingWorker.perform_async(doc.id)
end
