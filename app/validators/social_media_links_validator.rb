class SocialMediaLinksValidator < ActiveModel::Validator
  def initialize(opts = {})
    @attributes = opts[:attributes]
    @service_field = opts[:fields]["service_field"]
    @url_field = opts[:fields]["url_field"]
    super
  end

  def validate(record)
    @attributes.each do |attribute_name|
      arr = record.send(attribute_name.to_sym) || []
      arr.each_with_index do |social_media_service, index|
        service_name = social_media_service[@service_field]
        url = social_media_service[@url_field]

        next if service_name.blank? && url.blank?

        if validate_social_media_service(service_name, record, attribute_name, index)
          validate_social_media_link(url, service_name, record, attribute_name)
        end
      end
    end
  end

private

  def validate_social_media_service(service_name, record, attribute_name, index)
    @services ||= []

    if service_name.blank?
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "- account #{index + 1} must have a service selected.",
      )
      return false
    end

    if service_name != "Other" && @services.include?(service_name)
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "- you cannot add more than one \"#{service_name}\" account.",
      )
      return false
    end
    @services << service_name
  end

  def validate_social_media_link(url, service_name, record, attribute_name)
    if url.blank?
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "- the \"#{service_name}\" account must have a URL.",
      )
    elsif !valid_url?(url)
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "- the \"#{service_name}\" account has an invalid URL. Use the full URL, including https://",
      )
    elsif record.social_media_links.pluck("url").count(url) > 1
      unless record.errors.messages[attribute_name.to_sym].include?("- you cannot add more than one account with the URL \"#{url}\".")
        record.errors.add(
          attribute_name.to_sym,
          :invalid_social_media_link,
          message: "- you cannot add more than one account with the URL \"#{url}\".",
        )
      end
    end
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
