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

      duplicate_values(arr, @channel_field, exclude: "Other").each do |channel|
        record.errors.add(attribute_name.to_sym, :taken, message: "already has an account with a channel of \"#{channel}\"")
      end

      duplicate_values(arr, @url_field).each do |url|
        record.errors.add(attribute_name.to_sym, :taken, message: "already has an account with a URL of \"#{url}\"")
      end
    end
  end

private

  def duplicate_values(arr, field, exclude: nil)
    arr.map { |item| item[field] }
       .select(&:present?)
       .reject { |v| v == exclude }
       .group_by { |v| v }
       .select { |_, occurrences| occurrences.size > 1 }
       .keys
  end
end
