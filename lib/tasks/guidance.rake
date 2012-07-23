require 'logger'

namespace :guidance do
  task :import_csv, [:file, :topic, :organisation, :creator] => [:environment] do |t, args|
    topic = Topic.where(name: args[:topic]).first
    organisation = Organisation.where(name: args[:organisation]).first
    creator = User.where(email: args[:creator]).first
    unless topic && organisation && creator
      return "Must provide a valid topic, organisation, and creator"
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

  desc "Upload CSVs of Specialist Guidance content to the database"
end
