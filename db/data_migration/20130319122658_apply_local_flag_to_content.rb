require 'csv'

CSV.open(Rails.root.join('tmp/apply_local_flag.csv'),'w') do |output|
  output << %w(message document_id edition_id title policy)
end

policies = CSV.read('db/data_migration/20130319122658_apply_local_flag_to_content.csv', headers: false, encoding: "UTF-8")

policies.each do |row|
  title = row.first
  puts "Updating editions related to policy: #{title}"
  policy_versions = Policy.in_default_locale.where(edition_translations: {title: title})
  policy_versions.each do |v|
    v.update_column('relevant_to_local_government', true)
  end
  policy = policy_versions.last
  editions = policy.related_editions
  CSV.open(Rails.root.join('tmp/apply_local_flag.csv'),'a') do |output|
    output << ["Updated Policy",policy.document_id,policy.id,nil,title]
    if editions.any?
      editions.each do |edition|
        if edition.can_apply_to_local_government?
          edition.document.editions.each do |ev|
            ev.update_column('relevant_to_local_government', true)
            output << ["Updated Edition",ev.document_id,ev.id,ev.title,title]
          end
        end
      end
    else
      output << ["Warning: No editions found for policy",nil,nil,nil,title]
    end
  end
  GC.start
end
