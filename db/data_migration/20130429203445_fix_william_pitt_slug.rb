if william_pitt = Person.find_by_slug('william-lamb-pitt')
  william_pitt.update_column(:slug, 'william-pitt')
  puts "Changed William Pitt's slug"
end
