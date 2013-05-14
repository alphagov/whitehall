# encoding: UTF-8
require 'logger'
require 'cgi'
require 'set'
require 'uri'
require 'iconv'

def ensure_utf8(str)
  ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
  ic.iconv(str + ' ')[0..-2]
end

namespace :guidance do

  desc "Upload CSVs of Detailed Guidance content to the database"
  task :import_csv, [:file, :topic, :primary_mainstream_category, :organisation, :creator] => [:environment] do |t, args|
    topic = Topic.where(slug: args[:topic]).first
    primary_mainstream_category = MainstreamCategory.where(slug: args[:primary_mainstream_category]).first
    organisation = Organisation.where(slug: args[:organisation]).first
    creator = User.where(email: args[:creator]).first
    unless topic && creator && primary_mainstream_category
      unless topic
        puts "Must provide a valid topic slug"
      end
      unless creator
        puts "Must provide a valid creator email"
      end
      unless primary_mainstream_category
        puts "Must provide a primary mainstream category"
      end
      next
    end

    new_guides = 0
    updated_guides = 0
    unsaved_guides = 0

    CSV.foreach(args[:file], {:headers => true, :header_converters => :symbol}) do |row|
      title = ensure_utf8(row[:title])
      body = ensure_utf8(row[:markdown])

      # strip HRs from the content
      body = body.gsub(/\n(\*{2,})\n/, "")

      # strip "new window" text
      body = body.gsub(/\s-\sOpens in a new window/, "")

      # strip bold/strong markdown
      body = body.gsub(/\*\*([^\*]+)\*\*/, "\\1")

      Edition::AuditTrail.whodunnit = creator

      guide = DetailedGuide.where(title: title).last

      if guide
        guide = guide.create_draft(creator) if guide.published?
        guide.body = body
        guide.topics = [topic] if topic
        guide.organisations = [organisation] if organisation
      else
        guide = DetailedGuide.new(title: title, body: body, state: "draft", topics: [topic], creator: creator)
        if organisation
          guide.organisations = [organisation]
        end
        guide.primary_mainstream_category = primary_mainstream_category
      end

      was_new = guide.new_record?
      if guide.save
        if was_new
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

      Edition::AuditTrail.whodunnit = creator

      new_record = DetailedGuide.where(title: old_title).first

      if topic_id and new_record

        records_from_csv.add new_record.title
        results = DetailedGuide.where("body LIKE ?", "%topicId=#{topic_id}%").all

        if results
          found_urls += results.length.to_i
          results.each do |result|
            old_body = result.body
            to_match = /\([^\)]+topicId=#{topic_id}[^\\d)]*\)/
            to_match.match(old_body) do |matched|
              title = result.title
              new_url = Whitehall.url_maker.admin_edition_url(new_record, :host => args[:host])
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
