class EmailSignup::Alert
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
