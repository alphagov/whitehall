class SocialMediaLinksValidator < ActiveModel::Validator
  def initialize(opts = {})
    @attributes = opts[:attributes]
    super
  end

  def validate(record)
    @attributes.each do |attribute_name|
      seen_services = Set.new

      social_media_objects(record, attribute_name).each_with_index do |link, index|
        validate_duplicate_service(record, link, seen_services, index)
        validate_social_media_link(record, link, index, attribute_name)
      end
    end
  end

private

  def validate_duplicate_service(record, link, seen_services, index)
    return if link.social_media_service_id.blank? || link.social_media_service_id == "other"

    if seen_services.include?(link.social_media_service_id)
      error_message = "invalid: duplicate service '#{link.service_name}'"
      record.errors.add(:base, "Social media accounts #{error_message}", target_id: "social_media_accounts_attributes_#{index}_social_media_service_id")
    end
    seen_services << link.social_media_service_id
  end

  def social_media_objects(record, attribute_name)
    if record.respond_to?(:social_media_accounts)
      record.social_media_accounts
    else
      raw_links = record.read_attribute_for_validation(attribute_name)
      (raw_links || []).map { |data| TopicalEvent::SocialMediaLink.new(data) }
    end
  end

  def validate_social_media_link(record, link, index, attribute_name)
    return if link.marked_for_destruction? || link.valid?

    link.errors.each do |error|
      add_error_to_record(record, error, index, attribute_name)
    end
  end

  def add_error_to_record(record, error, index, attribute_name)
    if error.attribute == :url
      record.errors.add(:base, "Social media links #{error.message}", target_id: "social_media_accounts_attributes_#{index}_url")
    elsif error.attribute == :social_media_service_id
      record.errors.add(:base, "Social media accounts #{error.message}", target_id: "social_media_accounts_attributes_#{index}_social_media_service_id")
    else
      record.errors.add(attribute_name, error.message)
    end
  end
end
