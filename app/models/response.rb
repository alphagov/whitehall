class Response < ApplicationRecord
  include Attachable

  belongs_to :consultation, foreign_key: :edition_id

  validates :published_on, recent_date: true, presence: true
  validates_presence_of :summary, unless: :has_attachments
  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :summary

  def access_limited_object
    consultation
  end

  def access_limited?
    parent_attachable.access_limited?
  end

  def organisations
    parent_attachable.organisations
  end

  def alternative_format_contact_email
    consultation.alternative_format_contact_email
  end

  def publicly_visible?
    parent_attachable.publicly_visible?
  end

  def accessible_to?(user)
    parent_attachable.accessible_to?(user)
  end

  def unpublished?
    parent_attachable.unpublished?
  end

  def unpublished_edition
    parent_attachable.unpublished_edition
  end

  def can_order_attachments?
    true
  end

private

  def has_attachments
    attachments.any?
  end

  def parent_attachable
    consultation || Attachable::Null.new
  end
end
