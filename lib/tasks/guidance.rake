require 'logger'
require 'cgi'
require 'set'
require 'uri'

namespace :guidance do

  desc "Upload CSVs of Specialist Guidance content to the database"
  task :import_csv, [:file, :topic, :organisation, :creator] => [:environment] do |t, args|
    topic = Topic.where(slug: args[:topic]).first
    organisation = Organisation.where(slug: args[:organisation]).first
    creator = User.where(email: args[:creator]).first
    unless topic && creator
      unless topic
        puts "Must provide a valid topic slug"
      end
      unless creator
        puts "Must provide a valid creator email"
      end

      next
    end

    new_guides = 0
    updated_guides = 0
    unsaved_guides = 0

    CSV.foreach(args[:file], {:headers => true, :header_converters => :symbol}) do |row|
      title = row[:title]
      body = row[:markdown]

      # strip HRs from the content
      body = body.gsub(/\n(\*{2,})\n/, "")

      # strip "new window" text
      body = body.gsub(/\s-\sOpens in a new window/, "")

      # strip bold/strong markdown
      body = body.gsub(/\*\*([^\*]+)\*\*/, "\\1")

      PaperTrail.whodunnit = creator

      guide = SpecialistGuide.where(title: title).last

      if guide
        guide = guide.create_draft(creator) if guide.published?
        guide.body = body
        guide.topics = [topic] if topic
        guide.organisations = [organisation] if organisation
      else
        guide = SpecialistGuide.new(title: title, body: body, state: "draft", topics: [topic], creator: creator, paginate_body: false)
        if organisation
          guide.organisations = [organisation]
        end
      end

      if guide.save
        if guide.new_record?
          new_guides += 1
        else
          updated_guides += 1
        end
      else
        unsaved_guides += 1
        puts "Problem saving #{guide.title}: #{guide.errors.full_messages.to_sentence}"
      end
    end
    puts "#{new_guides} created, #{updated_guides} updated and #{unsaved_guides} failed to save"

  end

  desc "Maps business link URLs in the database to their admin equivalents"
  task :map_business_link_urls, [:file, :host, :creator] => [:environment] do |t, args|
    include Rails.application.routes.url_helpers
    include PublicDocumentRoutesHelper
    include Admin::EditionRoutesHelper

    creator = User.where(email: args[:creator]).first

    found_urls = 0
    edited_guides = 0

    records_from_csv = Set.new
    other_records = {}

    CSV.foreach(args[:file], {:headers => true, :header_converters => :symbol}) do |row|
      business_link_url = row[:link]
      old_title = row[:title]

      parts = CGI::parse(URI(business_link_url).query)
      topic_id = parts['topicId'][0]

      PaperTrail.whodunnit = creator

      new_record = SpecialistGuide.where(title: old_title).first

      if topic_id and new_record

        records_from_csv.add new_record.title
        results = SpecialistGuide.where("body LIKE ?", "%topicId=#{topic_id}%").all

        if results
          found_urls += results.length.to_i
          results.each do |result|
            old_body = result.body
            to_match = /\([^\)]+topicId=#{topic_id}[^\\d)]*\)/
            to_match.match(old_body) do |matched|
              title = result.title
              new_url = admin_edition_url(new_record, :host => args[:host])
              if ! other_records[title]
                other_records[title] = Set.new
              end
              other_records[title].add [topic_id, matched[0], new_url]
              body = old_body.gsub(to_match, "(#{new_url})")
              result.body = body
              result.save && edited_guides += 1
            end
          end
        end
      end
    end
    if found_urls > 0
      puts "#{found_urls} URLs found"
    end
    if edited_guides > 0
      puts "#{other_records.keys.to_set.length} guides updated"
      puts ""
      puts "The following guides not in the CSV were updated:"
      (other_records.keys.to_set - records_from_csv).each do |title|
        puts " - #{title}:"
        other_records[title].each do |link|
          puts " --- #{link}"
        end
      end
    end
  end

end
