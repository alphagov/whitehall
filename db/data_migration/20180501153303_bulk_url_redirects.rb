slug_changes = [
  { old_slug: 'data-engineer-levels-of-capability', new_slug: 'data-engineer-roles-skill-levels' },
  { old_slug: 'data-scientist-levels-of-capability', new_slug: 'data-scientist-roles-skill-levels' },
  { old_slug: 'performance-analyst-levels-of-capability', new_slug: 'performance-analyst-roles-skill-levels' },
  { old_slug: 'business-relationship-manager-levels-of-capability', new_slug: 'business-relationship-manager-roles-skill-levels' },
  { old_slug: 'change-and-release-manager-levels-of-capability', new_slug: 'change-and-release-manager-roles-skill-levels' },
  { old_slug: 'command-and-control-centre-manager-levels-of-capability', new_slug: 'command-and-control-centre-manager-roles-skill-levels' },
  { old_slug: 'engineer-application-operations-levels-of-capability', new_slug: 'engineer-application-operations-roles-skill-levels' },
  { old_slug: 'engineer-end-user-computing-levels-of-capability', new_slug: 'engineer-end-user-computing-roles-skill-levels' },
  { old_slug: 'engineer-infrastructure-operations-levels-of-capability', new_slug: 'engineer-infrastructure-operations-roles-skill-levels' },
  { old_slug: 'incident-manager-levels-of-capability', new_slug: 'incident-manager-roles-skill-levels' },
  { old_slug: 'it-service-manager-levels-of-capability', new_slug: 'it-service-manager-roles-skill-levels' },
  { old_slug: 'problem-manager-levels-of-capability', new_slug: 'problem-manager-roles-skill-levels' },
  { old_slug: 'service-desk-manager-levels-of-capability', new_slug: 'service-desk-manager-roles-skill-levels' },
  { old_slug: 'service-transition-manager-levels-of-capability', new_slug: 'service-transition-manager-roles-skill-levels' },
  { old_slug: 'business-analyst-levels-of-capability', new_slug: 'business-analyst-roles-skill-levels' },
  { old_slug: 'delivery-manager-levels-of-capability', new_slug: 'delivery-manager-roles-skill-levels' },
  { old_slug: 'product-manager-levels-of-capability', new_slug: 'product-manager-roles-skill-levels' },
  { old_slug: 'programme-delivery-manager-levels-of-capability', new_slug: 'programme-delivery-manager-role-skill-levels' },
  { old_slug: 'service-owner-levels-of-capability', new_slug: 'service-owner-role-skill-levels' },
  { old_slug: 'qat-analyst-levels-of-capability', new_slug: 'qat-analyst-roles-skill-levels' },
  { old_slug: 'test-engineer-levels-of-capability', new_slug: 'test-engineer-roles-skill-levels' },
  { old_slug: 'test-manager-levels-of-capability', new_slug: 'test-manager-roles-skill-levels' },
  { old_slug: 'data-architect-levels-of-capability', new_slug: 'data-architect-roles-skill-levels' },
  { old_slug: 'development-operations-levels-of-capability', new_slug: 'development-operations-roles-skill-levels' },
  { old_slug: 'infrastructure-engineer-levels-of-capability', new_slug: 'infrastructure-engineer-roles-skill-levels' },
  { old_slug: 'network-architect-levels-of-capability', new_slug: 'network-architect-roles-skill-levels' },
  { old_slug: 'security-architect-levels-of-capability', new_slug: 'security-architect-roles-skill-levels' },
  { old_slug: 'software-developer-levels-of-capability', new_slug: 'software-developer-roles-skill-levels' },
  { old_slug: 'technical-architect-levels-of-capability', new_slug: 'technical-architect-roles-skill-levels' },
  { old_slug: 'content-designer-levels-of-capability', new_slug: 'content-designer-roles-skill-levels' },
  { old_slug: 'content-strategist-levels-of-capability', new_slug: 'content-strategist-role-skill-levels' },
  { old_slug: 'graphic-designer-levels-of-capability', new_slug: 'graphic-designer-roles-skill-levels' },
  { old_slug: 'interaction-designer-levels-of-capability', new_slug: 'interaction-designer-roles-skill-levels' },
  { old_slug: 'service-designer-levels-of-capability', new_slug: 'service-designer-roles-skill-levels' },
  { old_slug: 'technical-writer-levels-of-capability', new_slug: 'technical-writer-roles-skill-levels' },
  { old_slug: 'user-researcher-levels-of-capability', new_slug: 'user-researcher-roles-skill-levels' }
]

slug_changes.each do |slug_change|
  document = Document.find_by(slug: slug_change[:old_slug])

  if document
    # remove the most recent edition from the search index
    edition = document.editions.published.last
    Whitehall::SearchIndex.delete(edition)

    # change the slug of the document and create a redirect from the original
    document.update_attributes!(slug: slug_change[:new_slug])
    PublishingApiDocumentRepublishingWorker.new.perform(document.id)
  else
    "Document can't be found with slug #{slug_change[:old_slug]}"
  end
end
