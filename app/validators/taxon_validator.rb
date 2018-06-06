class TaxonValidator < ActiveModel::Validator
  def validate(edition)
    if missing_taxons?(edition)
      edition.errors.add(
        :base,
        "<b>This document has not been published.</b> You need to add a topic before publishing.".html_safe
      )
    end
  end

private

  def missing_taxons?(edition)
    edition.can_be_tagged_to_taxonomy? && !edition.has_been_tagged?
  end
end
