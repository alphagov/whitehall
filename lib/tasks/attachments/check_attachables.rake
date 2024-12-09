desc "Check attachables"
task check_attachables: :environment do
  File.readlines("./lib/tasks/attachments/ads_to_check.txt", chomp: true).each do |line|
    attachment_data_id = line.split(",").first
    states = AttachmentData.find(attachment_data_id).attachments.map(&:attachable).map { |a| a&.state }
    if !valid_state(states)
      puts "NOT OK: #{attachment_data_id}: [#{states.join(', ')}]"
    else
      print "."
    end
  end
end

def valid_state(states)
  return false unless states[-1].nil?
  return false unless states.reject { |state| ["superseded", nil].include? state }.empty?

  true
end
