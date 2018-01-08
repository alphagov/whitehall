puts "Destroying dependencies for superseded editions"

dependencies_for_superseded_editions = EditionDependency.includes(:edition).all.select { |ed| ed.edition.superseded? }
EditionDependency.where(id: dependencies_for_superseded_editions.map(&:id)).destroy_all

puts "Done."
