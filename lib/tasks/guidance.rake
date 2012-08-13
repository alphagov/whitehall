require 'logger'
require 'cgi'

namespace :guidance do

  desc "Upload CSVs of Specialist Guidance content to the database"
  task :import_csv, [:file, :topic, :organisation, :creator] => [:environment] do |t, args|
    topic = Topic.where(slug: args[:topic]).first
    organisation = Organisation.where(slug: args[:organisation]).first
    creator = User.where(email: args[:creator]).first
    unless topic && organisation && creator
      unless topic
        puts "Must provide a valid topic slug"
      end
      unless organisation
        puts "Must provide a valid organisation slug"
      end
      unless creator
        puts "Must provide a valid creator email"
      end

      next
    end

    new_guides = 0
    updated_guides = 0

    CSV.foreach(args[:file], {:headers => true}) do |row|
      title = row[0]
      body = row[1]

      # strip HRs from the content
      body = body.gsub(/\n([\*\s]{2,})\n/, "")

      # strip "new window" text
      body = body.gsub(/\s-\sOpens in a new window/, "")

      # strip bold/strong markdown
      body = body.gsub(/\*\*([^\*]+)\*\*/, "\\1")

      PaperTrail.whodunnit = creator

      existing_guide = SpecialistGuide.where(title: title).first

      if existing_guide
        existing_guide.body = body
        existing_guide.save && updated_guides += 1
      else
        guide = SpecialistGuide.new(title: title, body: body, state: "draft", topics: [topic], organisations: [organisation], creator: creator, paginate_body: false)
        guide.save && new_guides += 1
      end
    end
    puts "#{new_guides} created and #{updated_guides} updated"

  end

  desc "Maps business link URLs in the database to their admin equivalents"
  task :map_business_link_urls, [:file, :host, :creator] => [:environment] do |t, args|
    include Rails.application.routes.url_helpers
    include PublicDocumentRoutesHelper
    include Admin::EditionRoutesHelper

    creator = User.where(email: args[:creator]).first

    found_urls = 0
    edited_guides = 0


    CSV.foreach(args[:file], {:headers => true}) do |row|
      business_link_url = row[0]
      old_title = row[1]

      parts = CGI::parse(business_link_url)
      topic_id = parts['topicId'][0]
      PaperTrail.whodunnit = creator
      new_record = SpecialistGuide.where(title: old_title).first
      if new_record
        results = SpecialistGuide.where("body LIKE ?", "%topicId=#{topic_id}%").all
        if results
          found_urls += results.length.to_i
          results.each do |result|
            old_body = result.body
            body = old_body.gsub(/\([^\)]+topicId=#{topic_id}[^\)]*\)/, "(#{admin_edition_url(new_record, :host => args[:host])})")
            result.body = body
            result.save && edited_guides += 1
          end
        end
      end
    end
    if found_urls > 0
      puts "#{found_urls} URLs found"
    end
    if edited_guides > 0
      puts "#{edited_guides} guides updated"
    end
  end

end
