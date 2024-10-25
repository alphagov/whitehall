desc "Report on AttachmentData in WH that should be marked as deleted"
task attachment_data_that_should_be_marked_as_deleted_in_wh: :environment do
  file = File.open("./lib/tasks/attachments/attachment_data_that_should_be_marked_as_deleted_in_wh.txt", "a")

  AttachmentData.find_each.map do |attachment_data|
    attachables = attachment_data.attachments.map(&:attachable).compact

    next unless attachables.any?
    next if attachables.detect { |attachable| !attachable.is_a?(Edition) }
    next if (attachables.map(&:state) - %w[superseded]).any?

    if !attachment_data.deleted?
      puts "#{attachment_data.id}, replaced: #{!!attachment_data.replaced_by_id}"
      file << "#{attachment_data.id},#{!!attachment_data.replaced_by_id},#{attachment_data.updated_at}" << "\n"
    end
  end

  file.close
end
