module Edition::AlternativeFormatProvider
  extend ActiveSupport::Concern

  # The following departments are taking place in a pilot scheme to use the accessible format
  # request form. DFE(6), DWP(10), DHSC(12), HMRC(25), DVSA(570), UKHSA(1328)
  ACCESSIBLE_FORMAT_REQUEST_PILOT_ORGANISATION_IDS = [6, 10, 12, 25, 570, 1328].freeze

  included do
    belongs_to :alternative_format_provider, class_name: Organisation.name # rubocop:disable Rails/ReflectionClassName

    validates :alternative_format_provider, presence: true, if: :alternative_format_provider_required?
    validate :alternative_format_provider_has_contact_email, if: :alternative_format_provider_required?
  end

  def alternative_format_provider_required?
    attachments.any? { |a| a.is_a?(FileAttachment) }
  end

  def alternative_format_contact_email
    if alternative_format_provider && alternative_format_provider.alternative_format_contact_email.present?
      alternative_format_provider.alternative_format_contact_email.strip
    else
      default_alternative_format_contact_email
    end
  end

  def default_alternative_format_contact_email
    "govuk-feedback@digital.cabinet-office.gov.uk"
  end

  def organisation_in_accessible_format_request_pilot?
    ACCESSIBLE_FORMAT_REQUEST_PILOT_ORGANISATION_IDS.include?(alternative_format_provider&.id)
  end

private

  def alternative_format_provider_has_contact_email
    if alternative_format_provider && alternative_format_provider.alternative_format_contact_email.blank?
      errors.add(:alternative_format_provider, "must have an email address set")
    end
  end
end
