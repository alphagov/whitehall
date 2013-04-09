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

  def self.valid_topics
    Classification.order(:name).where("(type = 'Topic' and published_policies_count <> 0) or (type = 'TopicalEvent')").alphabetical
  end
  def self.valid_topic_slugs
    valid_topics.map(&:slug) + ['all']
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
    valid_organisations_by_type.values.flatten.map(&:slug) + ['all']
  end

  def self.valid_document_types_by_type
    {
      publication_type: [DocumentTypeOptionForAllOfType.new('All publication types')] + Whitehall::PublicationFilterOption.all.sort_by { |o| o.label },
      announcement_type: [DocumentTypeOptionForAllOfType.new('All announcment types')] + Whitehall::AnnouncementFilterOption.all.sort_by { |o| o.label },
      policy_type: [DocumentTypeOptionForAllOfType.new('All policies')]
    }
  end
  def self.valid_document_type_slugs
    valid_document_types_by_type.map { |type_key, types|
      types.map { |type| "#{type_key}_#{type.slug}" }
    }.flatten + ['all']
  end

  protected
  def all_alerts_are_valid
    # [].all? is always true, so we won't get double validation errors
    # about length and validity of contents
    errors.add(:alerts, 'are invalid') unless alerts.all? { |a| a.valid? }
  end

  public
  class Alert
    include ActiveModel::Validations
    attr_accessor :document_type, :topic, :organisation, :info_for_local
    def initialize(args = {})
      args.symbolize_keys.each do |attr, value|
        self.__send__("#{attr}=", args[attr])
      end
    end

    def info_for_local
      # note this is mostly from ActiveRecord::ConnectionAdapters::Column
      if @info_for_local.nil? || (@info_for_local.is_a?(String) && @info_for_local.blank?)
        nil
      else
        [true, 1, '1', 't', 'T', 'true', 'TRUE'].include?(@info_for_local)
      end
    end
    alias :info_for_local? :info_for_local

    def document_generic_type
      if document_type == 'all'
        'all'
      else
        document_type.match(/\A(publication|announcement|policy)_type_/)[1]
      end
    end
    def document_specific_type
      if document_type == 'all'
        'all'
      else
        document_type.match(/\A(?:publication|announcement|policy)_type_(.*)\Z/)[1]
      end
    end

    validates :topic, :organisation, :document_type, presence: true
    validate :selected_topic_is_valid
    validate :selected_organisation_is_valid
    validate :selected_document_type_is_valid

    protected
    def selected_topic_is_valid
      if topic.present?
        errors.add(:topic, 'is not a valid topic') unless EmailSignup.valid_topic_slugs.include? topic
      end
    end

    def selected_organisation_is_valid
      if organisation.present?
        errors.add(:organisation, 'is not a valid organisation') unless EmailSignup.valid_organisation_slugs.include? organisation
      end
    end

    def selected_document_type_is_valid
      if document_type.present?
        errors.add(:document_type, 'is not a valid document type') unless EmailSignup.valid_document_type_slugs.include? document_type
      end
    end
  end

  class FeedUrlExtractor
    include Rails.application.routes.url_helpers
    default_url_options.merge!(host: Whitehall.public_host, protocol: Whitehall.public_protocol)

    def initialize(alert)
      @alert = alert
    end

    def extract_feed_url
      send("#{path_segment_name}_url", filters.merge(format: 'atom'))
    end

    def filters
      filters = {}
      if @alert.organisation && @alert.organisation != 'all'
        filters[:departments] = [@alert.organisation]
      end
      if @alert.topic && @alert.topic != 'all'
        filters[:topics] = [@alert.topic]
      end
      if @alert.document_specific_type != 'all'
        case @alert.document_generic_type
        when 'publication'
          filters[:publication_filter_option] = @alert.document_specific_type
        when 'announcement'
          filters[:announcement_filter_option] = @alert.document_specific_type
        end
      end
      filters
    end

    def path_segment_name
      case @alert.document_generic_type
      when 'publication'
        :publications
      when 'announcement'
        :announcements
      when 'policy'
        :policies
      when 'all'
        :atom_feed
      end
    end
  end

  class DocumentTypeOptionForAllOfType < Struct.new(:label)
    def slug
      'all'
    end
  end
end
