# All non-published/superseded editions that have an unpublishing.
non_published_editions_with_unpublishings = Edition.unscoped.
                                              joins(:unpublishing).
                                              includes(:document).
                                              where(state: %w[draft deleted])

# reject any editions that have subsequently been re-published
unpublished_editions = non_published_editions_with_unpublishings.reject do |edition|
  edition.document.published_edition.present?
end

# DataHygiene::PublishingApiRepublisher expects a scope.
unpublishing_scope = Unpublishing.where(edition_id: unpublished_editions.map(&:id))

DataHygiene::PublishingApiRepublisher.new(unpublishing_scope).perform
