# working_group is the name used for PolicyGroup in publishing-api land see:
# https://github.com/alphagov/whitehall/commit/0bf9ce56fa4a9f82552e7eb551a1cc3c95b7ec39
# for more detail.

# Enable (re)publishing of "/government/groups/criminal-justice-board".
#
# In production and integration, in content-store/publishing-api, there is a
# content_item with this base_path and the content_id:
# "8fd0b07e-c37a-4b99-9696-52323ad34c48". This doesn't match the content_id in
# Whitehall's database, which is: "3dd40620-7d1d-4344-820c-f051683be5fb". The
# consequence of that is that we aren't able to republish the working group
# because we're trying to overwrite a content_item but with a different
# content_id. That is only allowed if the item being replaced or doing the
# replacing is one of a few special types, such as "gone" or "redirect". See
# https://github.com/alphagov/publishing-api/blob/27ae02862e4705953a053c74bd94ce759a41544d/app/substitution_helper.rb
#
# Therefore, to be able to publish the criminal-justice-board content_item, we
# can publish a Gone item and then (re)publish the real thing over the top.
#
# I suspect this happened when a PolicyGroup with the slug was created,
# deleted and then recreated. Then it would have ended up with a different
# content_id. At the time, the PolicyGroup model was wired up to publish to
# publishing-api (via the PublishesToPublishingApi module) but deletes weren't
# handled. See:
# https://github.com/alphagov/whitehall/commit/0bf9ce56fa4a9f82552e7eb551a1cc3c95b7ec39
#
# and from the time:
# https://github.com/alphagov/whitehall/blob/0bf9ce56fa4a9f82552e7eb551a1cc3c95b7ec39/lib/publishes_to_publishing_api.rb
PublishingApiGoneWorker.new.perform("/government/groups/criminal-justice-board")

republisher = DataHygiene::PublishingApiRepublisher.new(PolicyGroup.all)
republisher.perform
