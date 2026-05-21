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
      @channels_seen = []
      @urls_seen = []
      @titles_seen = []

      arr.each_with_index do |social_media_account, index|
        channel_name = social_media_account[@channel_field]
        url = social_media_account[@url_field]
        title = social_media_account[@title_field]
        channel = { channel_name: channel_name, title: title }

        validate_social_media_channel(channel, index, record, attribute_name)
        validate_social_media_title(title, index, record, attribute_name)
        validate_social_media_url(url, index, record, attribute_name)
      end
    end
  end

private

  def validate_social_media_channel(channel, index, record, attribute_name)
    if channel[:channel_name].blank?
      record.errors.add(
        :"#{attribute_name}.#{index}.#{@channel_field}",
        :blank,
        message: "cannot be blank",
      )
    elsif @channels_seen.select { |c| c[:channel_name] == channel[:channel_name] && c[:title] == channel[:title] && c[:title].blank? }.any?
      record.errors.add(
        :"#{attribute_name}.#{index}.#{@channel_field}",
        :taken,
        message: "must be unique",
      )
    else
      @channels_seen << channel
    end
  end

  def validate_social_media_title(title, index, record, attribute_name)
    return if title.blank?

    if @titles_seen.include?(title)
      record.errors.add(
        :"#{attribute_name}.#{index}.#{@title_field}",
        :taken,
        message: "must be unique",
      )
    else
      @titles_seen << title
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
