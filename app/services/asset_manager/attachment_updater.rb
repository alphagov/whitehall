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

    # This logic will be eventually removed as part of cleaning up the feature flag for removing legacy_url_path
    if attachment_data.assets.empty?
      updates = []

      updates += AccessLimitedUpdates.call(attachment_data).to_a if access_limited
      updates += DraftStatusUpdates.call(attachment_data).to_a if draft_status
      updates += LinkHeaderUpdates.call(attachment_data).to_a if link_header
      updates += RedirectUrlUpdates.call(attachment_data).to_a if redirect_url
      updates += ReplacementIdUpdates.call(attachment_data).to_a if replacement_id

      combined_updates(updates).each(&:call)
    else
      attachment_data.assets.each do |asset|
        asset_attributes = get_asset_attributes(attachment_data, asset, access_limited, draft_status, link_header, redirect_url, replacement_id)

        next unless asset_attributes.any?

        AssetManager::AssetUpdater.call(asset.asset_manager_id, attachment_data, nil, asset_attributes.deep_stringify_keys)
      end
    end
  end

  def self.combined_updates(updates)
    grouped_updates = updates.group_by do |update|
      [update.attachment_data, update.legacy_url_path, update.asset_manager_id]
    end

    grouped_updates.map do |(attachment_data, legacy_url_path, asset_manager_id), updates_to_combine|
      new_attributes = updates_to_combine.each_with_object({}) do |update, hash|
        hash.merge!(update.new_attributes)
      end

      Update.new(asset_manager_id, attachment_data, legacy_url_path, new_attributes)
    end
  end

  def self.get_asset_attributes(attachment_data, asset, access_limited, draft_status, link_header, redirect_url, replacement_id)
    new_attributes = {
      access_limited_organisation_ids: access_limited ? get_access_limited(attachment_data) : nil,
      draft: draft_status ? get_draft(attachment_data) : nil,
      parent_document_url: link_header ? get_link_header(attachment_data) : nil,
      replacement_id: replacement_id ? get_replacement_id(attachment_data, asset) : nil,
    }.compact
    new_attributes.merge!(redirect_url: get_redirect_url(attachment_data)) if redirect_url

    new_attributes
  end

  def self.get_access_limited(attachment_data)
    return [] unless attachment_data.access_limited?

    AssetManagerAccessLimitation.for(attachment_data.access_limited_object)
  end

  def self.get_draft(attachment_data)
    (
      attachment_data.draft? &&
        !attachment_data.unpublished? &&
        !attachment_data.replaced?
    ) || (
      attachment_data.unpublished? &&
        !attachment_data.present_at_unpublish? &&
        !attachment_data.replaced?
    )
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
    return nil unless attachment_data.unpublished? && attachment_data.present_at_unpublish?

    attachment_data.unpublished_edition.unpublishing.document_url
  end

  def self.get_replacement_id(attachment_data, asset)
    return nil unless attachment_data.replaced?

    replacement = attachment_data.replaced_by
    replacement_asset = replacement.assets.where(variant: asset.variant).first
    if replacement_asset
      replacement_asset.asset_manager_id
    else
      replacement.assets.where(variant: Asset.variants[:original]).first.asset_manager_id
    end
  end
end
