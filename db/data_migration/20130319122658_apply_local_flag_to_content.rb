require 'csv'

CSV.open(Rails.root.join('tmp/apply_local_flag.csv'),'w') do |output|
  output << %w(message document_id edition_id title policy)

  CSV.read('db/data_migration/20130319122658_apply_local_flag_to_content.csv', headers: false, encoding: "UTF-8").each do |row|
    title = row.first
    puts "Updating editions related to policy: #{title}"
    editions = Policy.in_default_locale.where(edition_translations: {title: title}).first.related_editions.all
    if editions.any?
      editions.each do |edition|
        if edition.can_apply_to_local_government?
          edition.update_attribute(:relevant_to_local_government, true)
          output << ["Updated Edition",edition.document_id,edition.id,edition.title,title]
        end
      end
    else
      output << ["Warning: No editions found for policy",nil,nil,nil,title]
    end
  end
end
