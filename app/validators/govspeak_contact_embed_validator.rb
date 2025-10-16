class GovspeakContactEmbedValidator < ActiveModel::Validator
  def initialize(opts = {})
    @attributes = (opts[:attributes] || [opts[:attribute]]).compact
    super
  end

  def validate(record)
    @record = record
    @attributes.each { |attribute_name| validate_attribute_embeds_only_valid_contacts(attribute_name) }
  end

  def validate_attribute_embeds_only_valid_contacts(attribute_name)
    Govspeak::ContactsExtractor.new(@record.public_send(attribute_name)).extracted_contact_ids.each do |contact_id|
      contact = Contact.find_by(id: contact_id)
      @record.errors.add(attribute_name, :embedded_contact_invalid, message: "embeds contact (ID #{contact_id}) that doesn't exist") unless contact
    end

    if @record.respond_to?(:html_attachments)
      @record.html_attachments.each do |html_attachment|
        Govspeak::ContactsExtractor.new(html_attachment.public_send(attribute_name)).extracted_contact_ids.each do |contact_id|
          contact = Contact.find_by(id: contact_id)
          error_message = I18n.t("activerecord.errors.models.edition.attributes.html_attachments.missing_contact_reference", html_attachment_title: html_attachment.title, contact_id: contact_id)
          @record.errors.add(:html_attachments, error_message) unless contact
        end
      end
    end
  end
end
