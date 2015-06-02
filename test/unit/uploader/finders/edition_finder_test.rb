require 'test_helper'
require 'support/importer_test_logger'

class Whitehall::Uploader::Finders::EditionFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = ImporterTestLogger.new(@log_buffer)
    @line_number = 1
    @publication_finder = Whitehall::Uploader::Finders::EditionFinder.new(Publication, @log, @line_number)
  end

  test "returns the published edition of all policies found by the supplied slugs" do
    publication_1 = create(:published_publication, title: "Publication 1")
    publication_2 = create(:published_publication, title: "Publication 2")
    assert_equal [publication_1, publication_2], @publication_finder.find(publication_1.slug, publication_2.slug)
  end

  test "returns the draft edition of any policies found by the supplied slugs which have no published editions" do
    publication_1 = create(:published_publication, title: "Publication 1")
    publication_2 = create(:draft_publication, title: "Publication 2")
    assert_equal [publication_1, publication_2], @publication_finder.find(publication_1.slug, publication_2.slug)
  end

  test "returns the published edition even if a draft edition exists" do
    publication_1 = create(:published_publication, title: "Publication 1")
    publication_1_draft = publication_1.create_draft(create(:user))
    assert_equal [publication_1], @publication_finder.find(publication_1.slug)
  end

  test "does not find other edition types which have the same slug" do
    news_article = create(:published_news_article, title: "Publication 1")
    assert_equal [], @publication_finder.find(news_article.slug)
    assert_match %r{Unable to find Publication with slug '#{news_article.slug}'}, @log_buffer.string
  end

  test "ignores blank slugs" do
    assert_equal [], @publication_finder.find('', '')
  end

  test "returns an empty array if a publication can't be found for the given slug" do
    assert_equal [], @publication_finder.find('made-up-publication-slug')
  end

  test "logs a warning if a publication can't be found for the given slug" do
    @publication_finder.find('made-up-publication-slug')
    assert_match /Unable to find Publication with slug 'made-up-publication-slug'/, @log_buffer.string
  end

  test "returns an empty array if the publication for the given slug that cannot be found" do
    assert_equal [], @publication_finder.find('made-up-publication-slug')
  end

  test "ignores duplicate related policies" do
    publication_1 = create(:published_publication, title: "Publication 1")
    assert_equal [publication_1], @publication_finder.find(publication_1.slug, publication_1.slug)
  end
end
