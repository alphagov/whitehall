# all of these editions are DetailedGuides that have been Unpublished with a
# redirect (consolidated) but then either submitted again or submitted then
# rejected (all months ago). This is causing them to now 404 instead of redirecting
# on the live site and not be correctly republished during migration.
# Setting them to `draft` makes them behave correctly when they are republished
#
# There isn't a valid transition from submitted back to draft without publishing
# so this 'seems' like the best approach

edition_ids = [386_611, 538_971, 539_167, 539_189, 539_205, 580_614, 539_257, 580_652, 320_368, 276_354, 424_191, 231_079, 208_346, 586_588, 231_045, 231_062, 454_878, 438_503]
Edition.where(id: edition_ids).each do |edition|
  edition.state = "draft"
  edition.save!
end
