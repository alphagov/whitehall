module OrganisationsConcern
  extend ActiveSupport::Concern

  IDENTITY_ATTRIBUTES = %i[name acronym logo_formatted_name].freeze

private

  def without_unauthorised_identity_attributes(attributes)
    return attributes if can?(:edit_identity, @organisation)

    attributes.except(*IDENTITY_ATTRIBUTES)
  end
end
