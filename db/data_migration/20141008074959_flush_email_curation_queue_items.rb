class EmailCurationQueueItemNotifier < Whitehall::GovUkDelivery::Notifier
  def initialize(edition, email_curation_queue_item)
    super(edition)
    @email_curation_queue_item = email_curation_queue_item
  end

  def notify
    # {
    #   "id" => 15142,
    #   "edition_id"=>381908,
    #   "title"=>"Airports Commission announces inner Thames estuary decision",
    #   "summary"=>"The inner Thames estuary airport proposal not shortlisted.",
    #   "notification_date"=>2014-09-03 06:34:29 UTC
    # }
    if should_notify_govuk_delivery?
      Whitehall::GovUkDelivery::Worker.notify!(
        edition,
        @email_curation_queue_item['notification_date'],
        @email_curation_queue_item['title'],
        @email_curation_queue_item['summary']
      )
    end

    ActiveRecord::Base.connection.execute("DELETE FROM email_curation_queue_items WHERE id=#{@email_curation_queue_item['id']};")
  end
end

puts "Sending notifications to subscribers for email curation queue items and deleting them"

email_curation_queue_items = ActiveRecord::Base.connection.select_all("SELECT * FROM email_curation_queue_items;")
email_curation_queue_items.each do |email_curation_queue_item|
  edition = Edition.find(email_curation_queue_item['edition_id'])
  EmailCurationQueueItemNotifier.new(edition, email_curation_queue_item).notify

  print "."
end

puts "\nSent notifications for #{email_curation_queue_items.count} email curation queue items and deleted them."
