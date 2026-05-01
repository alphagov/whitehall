# This class is considered technical debt. We hope to remove it one day if we implement
# https://gov-uk.atlassian.net/browse/WHIT-2883?focusedCommentId=185941
#
# ==== WHAT THIS CODE DOES ====
#
# We allow converting from one configurable document type to another (within reason),
#  such as converting a world news story to a news story. Most conversions work fine
# because their associations are identical (e.g. news_story -> government_response)
# but world_news_story has different associations to the other subtypes. When
# converting to or from world_news_story, we want to clean up the redundant associations
# as otherwise that can present as a bug on the frontend (e.g. a world news story
# having its 'organisations' being surfaced as the organisations on the page, instead of
# the selected 'worldwide_organisations'. And given we hide the organisations field on
# the world news story form, it's not possible for publishers to fix it up themselves.)
#
# We therefore need to:
#   1. Remove the redundant associations in Whitehall's database, and
#   2. Patch the links in the Publishing API to remove the redundant associations from there too.
#
# But that's complicated by the fact that we dynamically determine which subset of associations
# to send to Publishing API (see `PublishingApi::PayloadBuilder::ConfigurableDocumentLinks`)
# so we can't just call `patch_links` and call it a day. We instead need to 'spoof' the
# configurable document type to pretend to be of the _previous_ content type, so that we can
# patch links to send an empty array (to remove the values in Publishing API).
#
# ==== WHY THIS CODE EXISTS ====
# The ideal solution outlined in Jira is deemed overly complex for our needs right now, because:
#
#   1. This is ONLY about 'news story subtype' → world news story conversion (and the reverse) -
#      no other content type conversions. All other news story subtype conversions are fine.
#   2. The document type conversion feature is not blocked - publishers are still free to convert
#      news article subtypes.
#   4. There's no expectation we'll roll out document type conversion more widely (e.g. topical
#      events → history pages).
#   5. It should only ever be used in response to human error, i.e. if FCDO have chosen the wrong
#      content type to begin with, despite the guidance.
#
# We did have a rake task to run to patch up things manually, in response to support tickets, but
# that required publishers remembering to raise tickets, and was a cause of toil for us. We also
# considered running said rake task on a cron, which would avoid the need for most support work,
# but publishers could still be caught in a window where their doc is a bit broken for up to 24
# hours. So we agreed we should just run the logic - self-contained in a nicely signposted
# hacky file - after every document conversion, to automatically clean up data at the point of
# conversion.

class StandardEdition::HygieneEnforcer
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def cleanup!
    if dirty_world_news_story?(edition)
      edition.organisations.delete_all
      patch_links_as_document_type(edition, "news_story")
    elsif dirty_other_news_article_subtype?(edition)
      edition.worldwide_organisation_documents.delete_all
      patch_links_as_document_type(edition, "world_news_story")
    end
  end

private

  def dirty_world_news_story?(edition)
    edition.configurable_document_type == "world_news_story" && edition.organisations.any?
  end

  def dirty_other_news_article_subtype?(edition)
    edition.configurable_document_type.in?(%w[news_story press_release government_response]) && edition.worldwide_organisations.any?
  end

  def patch_links_as_document_type(edition, document_type)
    # Temporarily pretend this document if of document type 'document_type', so that we send the correct
    # associations (e.g. empty 'worldwide_organisations' and 'world_locations' arrays for a doc that has
    # been converted from a "world_news_story") as links to Publishing API.
    edition.configurable_document_type = document_type
    Whitehall::PublishingApi.patch_links(edition)
  end
end
