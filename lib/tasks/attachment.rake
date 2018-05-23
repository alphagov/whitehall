namespace :attachment do
  desc 'List and delete attachments with invalid attachables'
  task delete_where_attachable_invalid: :environment do
    # adding 'attachable: nil' to this 'where' doesn't work here:
    # doing so only keeps those with a null attachable_id in the
    # database; but if the attachable_id is invalid but non-null, the
    # attachable will be nil:
    #
    # irb> Attachment.find(566845).attachable
    # => nil
    # irb> Attachment.find(566845).attachable_id
    # => 330497
    #
    Attachment.where(deleted: false).find_each do |attachment|
      next unless attachment.attachable == nil
      puts attachment.attachment_data.file.asset_manager_path if attachment.attachment_data && attachment.attachment_data.file
      attachment.destroy
    end
  end
end
