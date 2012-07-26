require 'logger'

namespace :guidance do
  desc "Import specialist guidance"

  task :import_csv, [:file, :topic, :organisation, :creator] => [:environment] do |t, args|

    desc "Upload CSVs of Specialist Guidance content to the database"

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

end
