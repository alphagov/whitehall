module Edition::AlternativeFormatProvider
  extend ActiveSupport::Concern

  included do
    belongs_to :alternative_format_provider, class_name: Organisation.name
  end

  def alternative_format_contact_email
    if alternative_format_provider && alternative_format_provider.alternative_format_contact_email.present? 
      alternative_format_provider.alternative_format_contact_email
    else
      default_alternative_format_contact_email
    end
  end

  def default_alternative_format_contact_email
    "govuk-feedback@digital.cabinet-office.gov.uk"
  end
end
