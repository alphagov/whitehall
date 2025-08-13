require "gds_api/publishing_api/special_route_publisher"

namespace :publishing_api do
  desc "Manually redirect already unpublished Statistics Announcements"
  # Statistics Announcements are not the same as other documents - once unpublished, they disappear for the user,
  # meaning users are unable to set different redirects or reasons for the removed statistics announcement
  task :redirect_unpublished_statistics_announcement, %i[slug alternative_url locale] => :environment do |_, args|
    args.with_defaults(locale: "en")

    results = StatisticsAnnouncement.unscoped.where(slug: args[:slug])
    if results.empty?
      puts "Could not find Statistics Announcement with slug #{args[:slug]}"
      next
    end
    if results.count > 1
      puts "More than one Statistics Announcement (including Unpublished) with slug #{args[:slug]}"
      next
    end
    if results.first.publishing_state != "unpublished"
      puts "Statistics Announcement with slug #{args[:slug]} is not unpublished"
      next
    end

    puts "Updating redirect URL..."
    statistics_announcement = results.first
    statistics_announcement.redirect_url = args[:alternative_url].strip
    statistics_announcement.save!

    puts "Unpublishing from Publishing API..."
    response = Services.publishing_api.unpublish(
      statistics_announcement.content_id,
      type: "redirect",
      locale: args[:locale],
      alternative_path: statistics_announcement.redirect_url,
    )

    puts response.inspect
  end

  namespace :redirect_html_attachments do
    desc "Redirect HTML Attachments to a given URL (dry run)"
    task :by_content_id_dry_run, %i[content_id destination] => :environment do |_, args|
      DataHygiene::PublishingApiHtmlAttachmentRedirector.call(args[:content_id], args[:destination], dry_run: true)
    end

    desc "Redirect HTML Attachments to a given URL (for reals)"
    task :by_content_id, %i[content_id destination] => :environment do |_, args|
      DataHygiene::PublishingApiHtmlAttachmentRedirector.call(args[:content_id], args[:destination], dry_run: false)
    end
  end
end
