module Edition::AlternativeFormatProvider
  extend ActiveSupport::Concern

  included do
    belongs_to :alternative_format_provider, class_name: Organisation.name

    validates :alternative_format_provider, presence: true, if: :alternative_format_provider_required?
    validate :alternative_format_provider_has_contact_email, if: :alternative_format_provider_required?
  end

  def alternative_format_provider_required?
    attachments.any?
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

  private

  def alternative_format_provider_has_contact_email
    if alternative_format_provider
      if alternative_format_provider.alternative_format_contact_email.blank?
        errors.add(:alternative_format_provider, "must have an email address set")
      end
    end
  end
end
