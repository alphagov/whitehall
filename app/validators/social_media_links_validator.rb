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
      arr.each do |social_media_service|
        service_name = social_media_service[@service_field]
        if validate_social_media_service(service_name, record, attribute_name)
          validate_social_media_link(social_media_service[@url_field], service_name, record, attribute_name)
        end
      end
    end
  end

private

  def validate_social_media_service(service_name, record, attribute_name)
    @services ||= []
    if @services.include?(service_name)
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "invalid: duplicate service '#{service_name}'",
      )
      return nil
    end
    @services << service_name
  end

  def validate_social_media_link(url, service_name, record, attribute_name)
    if url.blank?
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "invalid: no URL provided for '#{service_name}'",
      )
    elsif !valid_url?(url)
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "invalid: bad URL provided for '#{service_name}'",
      )
    end
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
