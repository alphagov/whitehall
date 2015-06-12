module PolicyMigrationHelpers
  def self.build_html_attachment_body(world_location, priorities, locale, url_maker, summary)
    callout = %|
$CTA
#{summary}
$CTA

|

    combined_body = callout

    priorities.each_with_index do |priority, index|
      combined_body += extract_priority(priority, locale, index, url_maker)
    end

    return combined_body
  end

  def self.extract_priority(priority, locale, index, url_maker)
    I18n.with_locale(locale) do
      appendix_title = "Appendix #{index+1}: #{priority.title}"

      puts "-- Adding priority ##{priority.id}: as #{appendix_title}"

      body = %|

###{appendix_title}

$CTA
The previous URL of this page was [#{url_maker.public_document_url(priority)}](#{url_maker.public_document_url(priority)})
$CTA

#{priority.body.gsub(/^(\s*[#]{2,})/, '\1#')}
|
    end
  end

  def self.merge_associations(associations)
    # Maintain priority order by zipping the associations together
    max_length = associations.map(&:length).max
    ([nil] * max_length).zip(associations).flatten.compact.uniq
  end

  def self.copy_and_merge_associations!(priorities, policy_paper)
    policy_paper.specialist_sectors = merge_associations(priorities.map(&:specialist_sectors))

    lead_organisations = merge_associations(priorities.map(&:lead_organisations))
    supporting_organisations = merge_associations(priorities.map(&:supporting_organisations))

    policy_paper.lead_organisations = lead_organisations
    policy_paper.supporting_organisations = supporting_organisations - lead_organisations
  end
end





gds_user = User.find_by!(name: "GDS Inside Government Team")
url_maker = Whitehall.url_maker
foreign_affairs = Topic.find_by(slug: "foreign-affairs")

CSV.open(Rails.root+"tmp/#{Time.zone.now.strftime('%F-%H-%M-%S')}-policy_paper_creation_output.csv", "wb") do |csv|
  csv << ["world_location_id", "worldwide_priority_id", "locale", "policy_paper_id"]

  WorldLocation.active.each do |world_location|
    puts %{Creating policy paper from world location ##{world_location.id}}

    title = "2010 to 2015 government worldwide priorities: #{world_location.name}"
    summary = "This is a copy of a document that showed the priorities the 2010 to 2015 Conservative and Liberal Democrat coalition government had about #{world_location.name}.

See [what the UK government is doing around the world](#{url_maker.world_locations_path})."

    priorities = world_location.editions.publicly_visible.where(type: "WorldwidePriority")

    unless priorities.any?
      puts %{-- No priorities available}
      puts
      next
    end

    locales = priorities.map(&:translations).flatten.map(&:locale).uniq

    priorities_by_locale = Hash.new {|hash, key| hash[key] = []}
    locales.each do |locale|
      priorities_by_locale[locale] += priorities.with_translations(locale)
    end

    alternative_format_provider = priorities_by_locale[:en].first.lead_organisations.first

    policy_paper = Publication.new(
      publication_type_id: PublicationType::PolicyPaper.id,
      first_published_at: priorities.first.first_published_at,
      political: true,
      creator: gds_user,
      alternative_format_provider: alternative_format_provider,
      world_locations: [world_location],
      topics: [foreign_affairs],
    )

    priorities_by_locale.each do |locale, priorities|
      unless priorities.any?
        puts %{-- No priorities in locale #{locale}}
        next
      end

      I18n.with_locale(locale) do
        policy_paper.title = title
        policy_paper.summary = summary
        policy_paper.body = priorities.map do |priority|
          "* #{priority.title}"
        end.join("\n")
      end
    end

    PolicyMigrationHelpers.copy_and_merge_associations!(priorities, policy_paper)

    if policy_paper.save
      puts %{Created policy paper ##{policy_paper.id} "#{policy_paper.title}" from world location ##{world_location.id}}

      incrementing_number = 0
      priorities_by_locale.each do |locale, priorities|
        next unless priorities.any?

        html_attachment_body = PolicyMigrationHelpers.build_html_attachment_body(world_location, priorities, locale, url_maker, summary)

        incrementing_number += 1
        position = case locale
        when :en
          0
        else
          incrementing_number
        end

        policy_paper.attachments << HtmlAttachment.new(
          title: title,
          ordering: position,
          locale: locale,
          govspeak_content: GovspeakContent.new(
            body: html_attachment_body,
            manually_numbered_headings: true,
          ),
        )

        puts %{-- Created HTML attachment for locale #{locale}}

        priorities.each do |priority|
          csv << [world_location.id, priority.id, locale, policy_paper.id]
        end
      end
    else
      policy_paper.errors.full_messages.each do |error|
        puts %{-- #{error}}

        puts %{---- #{policy_paper.body}} if error =~ /invalid formatting/

        if error =~ /Attachments/
          policy_paper.attachments.each do |attachment|
            puts %{---- #{attachment.errors.full_messages.join(',')}}
          end
        end
      end

      puts %{Failed to create policy paper from world location ##{world_location.id} "#{policy_paper.title}"}
    end

    puts
  end
end
