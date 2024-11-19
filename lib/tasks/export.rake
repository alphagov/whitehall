namespace :export do
  desc "Exports HTML attachments for a particular publication as JSON"
  task :html_attachments, [:slug] => :environment do |_t, args|
    edition = Document.find_by(slug: args[:slug]).live_edition

    result = edition.html_attachments.map do |a|
      {
        title: a.title,
        body: a.body,
        issued_date: a.created_at.strftime("%Y-%m-%d"),
        summary: edition.summary,
        slug: a.slug,
      }
    end
    puts result.to_json
  end
end
