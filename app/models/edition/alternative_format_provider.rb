module Edition::AlternativeFormatProvider
  extend ActiveSupport::Concern

  included do
    belongs_to :alternative_format_provider, class_name: Organisation.name
  end

  def alternative_format_contact_email
    (alternative_format_provider && alternative_format_provider.alternative_format_contact_email) || 
      default_alternative_format_contact_email
  end

  def default_alternative_format_contact_email
    "govuk-feedback@digital.cabinet-office.gov.uk"
  end
end
