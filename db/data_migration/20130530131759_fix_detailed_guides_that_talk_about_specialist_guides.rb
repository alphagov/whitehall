
def fix_specialist_guides_reference(edition)
  edition.body = edition.body.gsub(/\/specialist-guides\//, '/detailed-guides/')
end

all_dgs = DetailedGuide.where(state: ['published', 'draft']).includes(:document).map {|dg| dg.latest_edition }.uniq

puts "Looking at #{all_dgs.count} Detailed Guides"

mentioning_specialist_guides = all_dgs.select { |e| e.body =~ /\/specialist-guides\// }

puts "#{mentioning_specialist_guides.count} have /specialist-guides/ in their body"

by_state = mentioning_specialist_guides.group_by { |e| e.state}
by_state['draft'] ||= []
by_state['published'] ||= []

puts "Directly fixing references in #{by_state['draft'].count} drafts"
by_state['draft'].each do |e|
  fix_specialist_guides_reference(e)
  e.save(validate: false)
end

puts "Re-editioning and fixing references in #{by_state['published'].count} published editions"
acting_as = User.find_by_name("GDS Inside Government Team")
by_state['published'].each do |e|
  new_draft = e.create_draft(acting_as)
  new_draft.reload
  fix_specialist_guides_reference(new_draft)
  new_draft.change_note = 'Fixing references to specialist guides'
  new_draft.save
  EditionForcePublisher.new(new_draft, acting_as, new_draft.change_note)
end

puts "Fixed draft detailed guides:"
by_state['draft'].each do |e|
  puts Whitehall.url_maker.admin_detailed_guide_url(e, host: 'whitehall-admin.production.alphagov.co.uk', protocol: 'https')
end

puts "Fixed and re-published detailed guides:"
by_state['published'].each do |e|
  puts Whitehall.url_maker.admin_detailed_guide_url(e.latest_edition, host: 'whitehall-admin.production.alphagov.co.uk', protocol: 'https')
end

puts "Done!"
