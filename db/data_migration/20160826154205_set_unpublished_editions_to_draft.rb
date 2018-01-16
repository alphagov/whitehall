#all of these editions are DetailedGuides that have been Unpublished with a
#redirect (consolidated) but then either submitted again or submitted then
#rejected (all months ago). This is causing them to now 404 instead of redirecting
#on the live site and not be correctly republished during migration.
#Setting them to `draft` makes them behave correctly when they are republished
#
#There isn't a valid transition from submitted back to draft without publishing
#so this 'seems' like the best approach

edition_ids = [386611, 538971, 539167, 539189, 539205, 580614, 539257, 580652, 320368, 276354, 424191, 231079, 208346, 586588, 231045, 231062, 454878, 438503]
Edition.where(id: edition_ids).each do |edition|
  edition.state = "draft"
  edition.save!
end
