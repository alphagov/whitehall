module AssetData
  extend ActiveSupport::Concern

  included do
    has_many :assets,
             as: :assetable,
             inverse_of: :assetable
  end

  delegate :accessible_to?, to: :significant_attachable

  delegate :access_limited?, to: :last_attachable

  delegate :access_limited_object, to: :last_attachable

  delegate :unpublished?, to: :unpublished_attachable

  def significant_attachable
    significant_attachment.attachable || Attachable::Null.new
  end

  def last_attachable
    last_attachment.attachable || Attachable::Null.new
  end

  def unpublished_attachable
    unpublished_attachment&.attachable || Attachable::Null.new
  end

  def significant_attachment(**args)
    last_publicly_visible_attachment || last_attachment(**args)
  end

  def last_attachment(**args)
    filtered_attachments(**args).last || Attachment::Null.new
  end

  def unpublished_attachment
    attachments.reverse.detect { |a| a.attachable&.unpublished? }
  end

  def last_publicly_visible_attachment
    attachments.reverse.detect { |a| (a.attachable || Attachable::Null.new).publicly_visible? }
  end

  def filtered_attachments(include_deleted_attachables: false)
    if include_deleted_attachables
      attachments
    else
      attachments.select { |attachment| attachment.attachable.present? }
    end
  end

  def access_limitation
    return [] unless access_limited?

    AssetManagerAccessLimitation.for(access_limited_object)
  end

  def redirect_url
    return nil unless unpublished?

    unpublished_attachable.unpublishing.document_url
  end

  def attachable_url
    return nil if significant_attachable.blank?

    if significant_attachable.is_a?(Edition)
      url_for(significant_attachable)
    elsif significant_attachable.respond_to?(:parent_attachable) && significant_attachable.parent_attachable.is_a?(Edition)
      url_for(significant_attachable.parent_attachable)
    elsif significant_attachable.is_a?(PolicyGroup)
      significant_attachable.public_url
    end
  end

  def deleted?
    significant_attachment(include_deleted_attachables: true).deleted?
  end

  def draft?
    !significant_attachable.publicly_visible?
  end

  def needs_publishing?
    attachments.size == 1 && attachments.first.attachable.publicly_visible?
  end

  def needs_discarding?
    attachments.size == 1
  end

  def url_for(edition)
    if Edition::PRE_PUBLICATION_STATES.include?(edition.state)
      edition.public_url(draft: true)
    elsif edition.publicly_visible?
      edition.public_url
    end
  end
end
