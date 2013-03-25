to_fix = MainstreamCategory.where(title: 'Powers of entry').first

if to_fix
  to_fix.title = 'Policing and crime prevention'
  to_fix.slug = 'policing'
  if to_fix.save
    puts "Mainstream category '#{to_fix.title}' updated"
  end
end
