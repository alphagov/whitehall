unpublished_ids = Edition.unscoped.joins(:unpublishing).includes(:document).where(state: ['draft', 'deleted']).reject {|e| e.document.published_edition.present? }.map(&:id)
DataHygiene::PublishingApiRepublisher.new(Edition.unscoped.where(id: unpublished_ids)).perform
