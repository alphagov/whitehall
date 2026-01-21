class SocialMediaLinksValidator < ActiveModel::Validator
  def initialize(opts = {})
    @attributes = opts[:attributes]
    @service_field = opts[:service_field]
    @url_field = opts[:url_field]
    super
  end

  def validate(record)
    @attributes.each do |attribute_name|
      arr = record.send(attribute_name.to_sym) || []
      arr.each do |social_media_service|
        if (service = validate_social_media_service(social_media_service[@service_field], record, attribute_name))
          validate_social_media_link(social_media_service[@url_field], service, record, attribute_name)
        end
      end
    end
  end

private

  def validate_social_media_service(service_id, record, attribute_name)
    @services ||= []
    service = SocialMediaService.find_by(id: service_id)
    if service.nil?
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "invalid: unknown service with ID '#{service_id}'",
      )
      return nil
    end
    if @services.include?(service_id)
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "invalid: duplicate service '#{service.name}'",
      )
      return nil
    end
    @services << service_id
    service
  end

  def validate_social_media_link(url, service, record, attribute_name)
    if url.blank?
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "invalid: no URL provided for '#{service.name}'",
      )
    elsif !valid_url?(url)
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "invalid: bad URL provided for '#{service.name}'",
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
