platform = Whitehall.platform

connection = Fog::Storage.new({
 provider: 'AWS',
 aws_secret_access_key: Whitehall.aws_secret_access_key,
 aws_access_key_id: Whitehall.aws_access_key_id,
 region: 'eu-west-1'
})

directory = connection.directories.detect do |d|
  d.key == "whitehall-frontend-#{platform}"
end

class PageReceiver
  attr_reader :number_of_pages
  def page_count(count)
    @number_of_pages = count
  end
end

Attachment.all.each do |attachment|
  next unless attachment.number_of_pages.blank?
  file = directory.files.get(attachment.file.path)
  next unless file.present?
  receiver = PageReceiver.new
  reader = PDF::Reader.string(file.body, receiver, pages: false)
  puts "updating attachment ID: %s" % attachment.id
  attachment.update_attributes!(number_of_pages: receiver.number_of_pages)
end
