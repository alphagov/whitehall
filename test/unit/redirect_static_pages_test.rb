require "test_helper"
require "govuk-content-schema-test-helpers"

class RedirectStaticPagesTest < ActiveSupport::TestCase
  test 'sends static pages to rummager and publishing api' do
    expect_redirection(RedirectStaticPages.new.pages)
    RedirectStaticPages.new.redirect
  end

  def expect_redirection(pages)
    pages.each do |page|
      PublishingApiRedirectWorker.any_instance.expects(:perform).with(
        page[:content_id],
        page[:target_path],
        "en",
      )
    end
  end
end
