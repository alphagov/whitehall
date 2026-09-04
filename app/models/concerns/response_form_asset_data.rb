module ResponseFormAssetData
  extend ActiveSupport::Concern

  delegate :unpublished?, to: :attachable
  delegate :access_limited?, to: :attachable
  delegate :access_limited_object, to: :attachable

  def deleted?
    false
  end

  def replaced?
    false
  end

  def draft?
    !attachable.publicly_visible?
  end

  def access_limitation_organisation_ids
    return [] unless access_limited?

    AssetManagerAccessLimitation.for(access_limited_object, :organisations) || []
  end

  def access_limitation_individual_ids
    return [] unless access_limited?

    AssetManagerAccessLimitation.for(access_limited_object, :users) || []
  end

  def attachable_url
    return nil if attachable.new_record?

    if Edition::PRE_PUBLICATION_STATES.include?(attachable.state)
      attachable.public_url(draft: true)
    elsif attachable.publicly_visible?
      attachable.public_url
    end
  end

  def auth_bypass_ids
    [attachable.auth_bypass_id].compact
  end

  def last_attachable
    attachable
  end

  def needs_publishing?
    attachable.publicly_visible?
  end
end
