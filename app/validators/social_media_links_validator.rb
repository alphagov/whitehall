class SocialMediaLinksValidator < ActiveModel::Validator
  def initialize(opts = {})
    @attributes = opts[:attributes]
    @service_field = opts[:fields]["service_field"]
    @url_field = opts[:fields]["url_field"]
    @title_field = opts[:fields]["title_field"]
    super
  end

  def validate(record)
    @attributes.each do |attribute_name|
      @services = []
      @titles = []
      arr = record.send(attribute_name.to_sym) || []
      arr.each_with_index do |social_media_service, index|
        service_name = social_media_service[@service_field]
        title = @title_field ? social_media_service[@title_field] : nil
        if validate_social_media_service(service_name, record, attribute_name, index)
          validate_social_media_link(social_media_service[@url_field], service_name, record, attribute_name)
          validate_display_name(title, record, attribute_name)
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
        message: "contains an account (\"Social media account #{index + 1}\") without a service selected.",
      )
      return false
    end

    if service_name != "Other" && @services.include?(service_name)
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "contains another account with a service of \"#{service_name}\".",
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
        message: "contains a \"#{service_name}\" account without a URL.",
      )
    elsif !valid_url?(url)
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "contains a \"#{service_name}\" account with an invalid URL - use the full URL, including https://",
      )
    elsif record.social_media_links.pluck("url").count(url) > 1
      unless record.errors.messages[attribute_name.to_sym].include?("already has an account with a URL of \"#{url}\".")
        record.errors.add(
          attribute_name.to_sym,
          :invalid_social_media_link,
          message: "already has an account with a URL of \"#{url}\".",
        )
      end
    end
  end

  def validate_display_name(title, record, attribute_name)
    return unless @title_field
    return if title.blank?

    if @titles.include?(title)
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "already has an account with a title of \"#{title}\".",
      )
    else
      @titles << title
    end
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
