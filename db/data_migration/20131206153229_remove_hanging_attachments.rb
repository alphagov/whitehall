puts "Processing #{Attachment.count} attachments"

Edition.unscoped {
  hanging = Attachment.includes(:attachable).select { |a|
    a.attachable.nil?
  }
  puts "Removing #{hanging.length} hanging attachments"
  hanging.each { |a|
    a.destroy
  }
}
