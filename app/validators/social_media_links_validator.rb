class SocialMediaLinksValidator < ActiveModel::Validator
  def initialize(opts = {})
    @attributes = opts[:attributes]
    @channel_field = opts[:fields]["service_field"]
    @url_field = opts[:fields]["url_field"]
    @title_field = opts[:fields]["title_field"]

    super
  end

  def validate(record)
    @attributes.each do |attribute_name|
      arr = record.send(attribute_name.to_sym) || []

      arr.each_with_index do |social_media_account, index|
        channel_name = social_media_account[@channel_field]
        url = social_media_account[@url_field]
        title = social_media_account[@title_field]
        channel = { channel_name: channel_name, title: title }

        validate_social_media_channel(channel, index, record, attribute_name)
        validate_social_media_title(title, channel_name, index, record, attribute_name)
        validate_social_media_url(url, index, record, attribute_name)
      end
    end
  end

private

  def validate_social_media_channel(channel, index, record, attribute_name)
    @channels_seen ||= []
    if channel[:channel_name].blank?
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "Social media channel #{index + 1} service name cannot be blank",
      )
      return false
    end
    @channels_seen << channel
  end

  def validate_social_media_title(title, channel_name, index, record, attribute_name)
    @titles_seen ||= []
    title ||= channel_name
    return if title.blank?

    if @titles_seen.include?(title)
      record.errors.add(
        attribute_name.to_sym,
        :taken,
        message: "Social media channel #{index + 1} title must be unique",
      )
    else
      @titles_seen << title
    end
  end

  def validate_social_media_url(url, index, record, attribute_name)
    @urls_seen ||= []
    if url.blank?
      record.errors.add(
        attribute_name.to_sym,
        :blank,
        message: "Social media channel #{index + 1} URL cannot be blank",
      )
    elsif !valid_url?(url)
      record.errors.add(
        attribute_name.to_sym,
        :invalid,
        message: "Social media channel #{index + 1} URL is invalid - use the full URL, including https://",
      )
    elsif @urls_seen.include?(url)
      record.errors.add(
        attribute_name.to_sym,
        :taken,
        message: "Social media channel #{index + 1} URL must be unique",
      )
    else
      @urls_seen << url
    end
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
