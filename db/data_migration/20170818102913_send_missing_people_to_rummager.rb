slugs = %w(
  nick-hurd
  nick-gibb
  damian-green
  brandon-lewis
  elizabeth-truss
  greg-hands
  claire-perry
  andrea-leadsom
  lord-ashton-of-hyde
  rory-stewart
  stephen-barclay
  richard-harrington
  caroline-nokes
  lord-oshaughnessy
  david-rutley
  rebecca-harris
  mike-freer
  nigel-adams
  stuart-andrew
  craig-whittaker
  ian-duncan
  david-hall--2
  david-reid
  duncan-thompson--2
  david-reed
  ben-merrick
)

missing_people = Person.where(slug: slugs)

missing_people.map(&:update_in_search_index)
