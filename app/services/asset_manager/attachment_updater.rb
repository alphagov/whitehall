class AssetManager::AttachmentUpdater
  def self.call(
    attachment_data,
    access_limited: false,
    draft_status: false,
    link_header: false,
    redirect_url: false,
    replacement_id: false
  )
    return if attachment_data.deleted?

    attachment_data.assets.each do |asset|
      asset_attributes = get_asset_attributes(attachment_data, asset, access_limited, draft_status, link_header, redirect_url, replacement_id)

      next unless asset_attributes.any?

      AssetManager::AssetUpdater.call(asset.asset_manager_id, attachment_data, nil, asset_attributes.deep_stringify_keys)
    end
  end

  def self.get_asset_attributes(attachment_data, asset, access_limited, draft_status, link_header, redirect_url, replacement_id)
    new_attributes = {
      access_limited_organisation_ids: access_limited ? get_access_limited(attachment_data) : nil,
      draft: draft_status ? get_draft(attachment_data) : nil,
      parent_document_url: link_header ? get_link_header(attachment_data) : nil,
      replacement_id: replacement_id ? get_replacement_id(attachment_data, asset.variant) : nil,
    }.compact
    new_attributes.merge!(redirect_url: get_redirect_url(attachment_data)) if redirect_url

    new_attributes
  end

  def self.get_access_limited(attachment_data)
    return [] unless attachment_data.access_limited?

    AssetManagerAccessLimitation.for(attachment_data.access_limited_object)
  end

  def self.get_draft(attachment_data)
    attachment_data.draft? &&
      !attachment_data.unpublished? &&
      !attachment_data.replaced?
  end

  def self.get_link_header(attachment_data)
    visible_edition = attachment_data.visible_edition_for(nil)
    draft_edition = attachment_data.draft_edition
    if visible_edition.blank? && draft_edition
      draft_edition.public_url(draft: true)
    elsif visible_edition.present?
      visible_edition.public_url
    end
  end

  def self.get_redirect_url(attachment_data)
    return nil unless attachment_data.unpublished?

    attachment_data.unpublished_edition.unpublishing.document_url
  end

  def self.get_replacement_id(replaced_attachment_data, variant)
    return nil unless replaced_attachment_data.replaced?

    replacement = replaced_attachment_data.replaced_by
    replacement_asset = replacement.assets.where(variant:).first

    if replacement_asset
      replacement_asset.asset_manager_id
    else
      original_variant = replacement.assets.where(variant: Asset.variants[:original]).first

      original_variant ? original_variant.asset_manager_id : nil
    end
  end
end
