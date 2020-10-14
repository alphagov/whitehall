PUBLISHED_AND_PUBLISHABLE_STATES = %w[published draft archived submitted rejected scheduled].freeze
EDITIONS_WITH_NATIONAL_APPLICABILITY = %w[DetailedGuide Publication Consultation].freeze

edition_scope = Edition.where(type: EDITIONS_WITH_NATIONAL_APPLICABILITY).where(state: PUBLISHED_AND_PUBLISHABLE_STATES)

def update_all_nation_applicability(edition)
  if edition.nation_inapplicabilities.any?
    edition.update_column(:all_nation_applicability, false)
  end
end

edition_scope.find_each { |edition| update_all_nation_applicability(edition) }
