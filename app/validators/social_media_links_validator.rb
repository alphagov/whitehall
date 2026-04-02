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
      arr.each_with_index do |social_media_account, index|
        channel_name = social_media_account[@channel_field]
        url = social_media_account[@url_field]

        channel_valid = validate_channel(channel_name, url, record, attribute_name, index)
        validate_social_media_link(url, channel_name, index, record, attribute_name) if channel_valid
      end
    end
  end

private

  def validate_channel(channel_name, url, record, attribute_name, index)
    @channels ||= []

    if channel_name.blank?
      record.errors.add(
        :"#{attribute_name}.#{index}.#{@channel_field}",
        :blank,
        message: "cannot be blank (account #{index + 1})",
      )
      if url.blank?
        record.errors.add(
          :"#{attribute_name}.#{index}.#{@url_field}",
          :blank,
          message: "cannot be blank (account #{index + 1})",
        )
      end
      return false
    end

    if channel_name != "Other" && @channels.include?(channel_name)
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "contains another account with a channel of \"#{channel_name}\".",
      )
      return false
    end
    @channels << channel_name
  end

  def validate_social_media_link(url, channel_name, index, record, attribute_name)
    if url.blank?
      record.errors.add(
        :"#{attribute_name}.#{index}.#{@url_field}",
        :blank,
        message: "cannot be blank (account #{index + 1})",
      )
    elsif !valid_url?(url)
      record.errors.add(
        attribute_name.to_sym,
        :invalid_social_media_link,
        message: "contains a \"#{channel_name}\" account with an invalid URL - use the full URL, including https://",
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

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
