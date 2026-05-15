class SocialMediaLinksValidator < ActiveModel::Validator
  def initialize(opts = {})
    @attributes = opts[:attributes]
    @channel_field = opts[:fields]["service_field"]
    @url_field = opts[:fields]["url_field"]
    super
  end

  def validate(record)
    @attributes.each do |attribute_name|
      arr = record.send(attribute_name.to_sym) || []
      @channels_seen = []
      @urls_seen = []

      arr.each_with_index do |social_media_account, index|
        channel_name = social_media_account[@channel_field]
        url = social_media_account[@url_field]

        validate_social_media_channel(channel_name, index, record, attribute_name)
        validate_social_media_url(url, index, record, attribute_name)
      end
    end
  end

private

  def validate_social_media_channel(channel_name, index, record, attribute_name)
    if channel_name.blank?
      record.errors.add(
        :"#{attribute_name}.#{index}.#{@channel_field}",
        :blank,
        message: "cannot be blank",
      )
    elsif channel_name != "Other" && @channels_seen.include?(channel_name)
      record.errors.add(
        :"#{attribute_name}.#{index}.#{@channel_field}",
        :taken,
        message: "must be unique",
      )
    else
      @channels_seen << channel_name
    end
  end

  def validate_social_media_url(url, index, record, attribute_name)
    if url.blank?
      record.errors.add(
        :"#{attribute_name}.#{index}.#{@url_field}",
        :blank,
        message: "cannot be blank",
      )
    elsif !valid_url?(url)
      record.errors.add(
        :"#{attribute_name}.#{index}.#{@url_field}",
        :invalid,
        message: "is invalid - use the full URL, including https://",
      )
    elsif @urls_seen.include?(url)
      record.errors.add(
        :"#{attribute_name}.#{index}.#{@url_field}",
        :taken,
        message: "must be unique",
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
