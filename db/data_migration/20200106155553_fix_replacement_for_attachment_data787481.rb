attachment_data_to_modify = AttachmentData.find(787481)

# 845347 isn't the replacement, but use it to find it. This avoids the
# situation where the replacement changes before this code runs
replacement = AttachmentData.find(845347).replaced_by

attachment_data_to_modify.replace_with!(replacement)

AssetManager::AttachmentUpdater.call(attachment_data_to_modify, replacement_id: true)
