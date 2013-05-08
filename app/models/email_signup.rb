class EmailSignup
  # pull in enough of active model to be able to use this in a form
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def persisted?
    false
  end

  validates :alerts, length: { minimum: 1 }
  validate :all_alerts_are_valid

  def alerts=(new_alerts)
    @alerts = Array.wrap(new_alerts).map { |new_alert| build_alert(new_alert) }
  end

  def alerts
    @alerts || []
  end

  def build_alert(args = {})
    case args
    when EmailSignup::Alert
      args
    when Hash
      EmailSignup::Alert.new(args)
    else
      raise ArgumentError, "can't construct an Alert out of #{args.inspect}"
    end
  end

  def self.valid_topics_by_type
    {
      topic: Topic.where("published_policies_count <> 0").alphabetical,
      topical_event: TopicalEvent.alphabetical
    }
  end

  def self.valid_topic_slugs
    valid_topics_by_type.map { |type, topics| topics.map(&:slug) }.flatten + ['all']
  end

  def self.valid_organisations_by_type
    ministerial_department_type = OrganisationType.find_by_name('Ministerial department')
    sub_organisation_type = OrganisationType.find_by_name('Sub-organisation')
    {
      ministerial: Organisation.with_translations.where("organisation_type_id = ? AND govuk_status ='live'", ministerial_department_type),
      other: Organisation.with_translations.where("organisation_type_id NOT IN (?,?) AND govuk_status='live'", ministerial_department_type, sub_organisation_type)
    }
  end

  def self.valid_organisation_slugs
    valid_organisations_by_type.map { |type, orgs| orgs.map(&:slug) }.flatten + ['all']
  end

  def self.valid_document_types_by_type
    {
      publication_type: [DocumentTypeOptionForAllOfType.new('All publication types')] + Whitehall::PublicationFilterOption.all.sort_by { |o| o.label },
      announcement_type: [DocumentTypeOptionForAllOfType.new('All announcement types')] + Whitehall::AnnouncementFilterOption.all.sort_by { |o| o.label },
      policy_type: [DocumentTypeOptionForAllOfType.new('All policies')]
    }
  end

  def self.valid_document_type_slugs
    valid_document_types_by_type.map { |type_key, types|
      types.map { |type| "#{type_key}_#{type.slug}" }
    }.flatten + ['all']
  end

  def self.valid_policies
    Policy.published.alphabetical
  end

  def self.valid_policy_slugs
    valid_policies.map(&:slug) + ['all']
  end

  protected
  def all_alerts_are_valid
    # [].all? is always true, so we won't get double validation errors
    # about length and validity of contents
    errors.add(:alerts, 'are invalid') unless alerts.all? { |a| a.valid? }
  end

  class DocumentTypeOptionForAllOfType < Struct.new(:label)
    def slug
      'all'
    end
  end
end
