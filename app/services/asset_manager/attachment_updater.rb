class AssetManager::AttachmentUpdater
  def self.call(
    attachment_data,
    access_limited: false,
    draft_status: false,
    link_header: false,
    redirect_url: false,
    replacement_id: false
  )
    updates = []

    updates += AccessLimitedUpdates.call(attachment_data).to_a if access_limited
    updates += DraftStatusUpdates.call(attachment_data).to_a if draft_status
    updates += LinkHeaderUpdates.call(attachment_data).to_a if link_header
    updates += RedirectUrlUpdates.call(attachment_data).to_a if redirect_url
    updates += ReplacementIdUpdates.call(attachment_data).to_a if replacement_id

    self.combined_updates(updates).each(&:call)
  end

  def self.combined_updates(updates)
    grouped_updates = updates.group_by do |update|
      [update.attachment_data, update.legacy_url_path]
    end

    grouped_updates.map do |(attachment_data, legacy_url_path), updates_to_combine|
      new_attributes = updates_to_combine.each_with_object({}) do |update, hash|
        hash.merge!(update.new_attributes)
      end

      Update.new(attachment_data, legacy_url_path, new_attributes)
    end
  end
end
