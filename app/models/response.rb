class Response < ApplicationRecord
  include Attachable

  belongs_to :consultation, foreign_key: :edition_id
  belongs_to :call_for_evidence, foreign_key: :edition_id


  validates :published_on, recent_date: true, presence: true
  validates :summary, presence: { unless: :has_attachments }
  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :summary
  delegate :auth_bypass_id, to: :consultation

  def access_limited_object
    consultation
  end

  delegate :access_limited?, to: :parent_attachable

  delegate :organisations, to: :parent_attachable

  delegate :alternative_format_contact_email, to: :consultation

  delegate :publicly_visible?, to: :parent_attachable

  delegate :accessible_to?, to: :parent_attachable

  delegate :unpublished?, to: :parent_attachable

  delegate :unpublished_edition, to: :parent_attachable

  def can_order_attachments?
    true
  end

  def allows_html_attachments?
    true
  end

  def path_name
    to_model.class.name.underscore
  end

  delegate :public_timestamp, :first_published_version?, :slug, :document, :images, :content_id, to: :consultation

private

  def has_attachments
    attachments.any?
  end

  def parent_attachable
    consultation || Attachable::Null.new
  end
end
