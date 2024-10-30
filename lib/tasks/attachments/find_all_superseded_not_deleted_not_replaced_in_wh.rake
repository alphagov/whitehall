desc "Report on AttachmentData in WH that should be marked as deleted"
task find_all_superseded_not_deleted_not_replaced_in_wh: :environment do
  file = File.open("./lib/tasks/attachments/find_all_superseded_not_deleted_not_replaced_in_wh.txt", "a")

  AttachmentData.find_each.map do |attachment_data|
    next unless attachment_data.replaced_by_id.nil?

    attachables = attachment_data.attachments.map(&:attachable).compact

    next unless attachables.any?
    next if attachables.detect { |attachable| !attachable.is_a?(Edition) }
    next if (attachables.map(&:state) - %w[superseded]).any?

    next unless attachment_data.deleted?

    puts "AD: #{attachment_data.id} not deleted and not replaced in WH"
    file << "#{attachment_data.id}" << "\n"
  end

  file.close
end
