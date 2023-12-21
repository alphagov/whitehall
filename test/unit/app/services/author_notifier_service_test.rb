require "test_helper"

class AuthorNotifierServiceTest < ActiveSupport::TestCase
  setup { ActionMailer::Base.deliveries.clear }

  test "notifies users" do
    edition = create(:edition)
    creator = edition.creator
    second_author = create(:gds_editor)
    edition.authors << second_author

    AuthorNotifierService.new(edition).notify!

    first_notification = ActionMailer::Base.deliveries.first
    assert_equal creator.email, first_notification.to[0]
    assert_match(/'#{edition.title}' has been published/, first_notification.subject)

    second_notification = ActionMailer::Base.deliveries.last
    assert_equal second_author.email, second_notification.to[0]
    assert_match(/'#{edition.title}' has been published/, second_notification.subject)
  end

  test "skips any users that are passed in" do
    edition = create(:edition)
    creator = edition.creator
    second_author = create(:gds_editor)
    edition.authors << second_author

    AuthorNotifierService.new(edition, second_author).notify!

    assert_equal 1, ActionMailer::Base.deliveries.size

    first_notification = ActionMailer::Base.deliveries.first
    assert_equal creator.email, first_notification.to[0]
    assert_match(/'#{edition.title}' has been published/, first_notification.subject)
  end

  test "does not raise an error if an email cannot be sent via notify in integration" do
    raises_exception = lambda { |_author, _edition, _edition_admin_url, _public_document_url|
      response = Minitest::Mock.new
      ENV["SENTRY_CURRENT_ENV"] = "integration-blue-aws"
      response.expect :code, 400
      response.expect :body, "Can't send to this recipient using a team-only API key"
      raise Notifications::Client::BadRequestError, response
    }

    MailNotifications.stub(:edition_published, raises_exception) do
      ActionMailer::Base.deliveries.clear
      edition = create(:edition)
      assert_nothing_raised do
        AuthorNotifierService.new(edition).notify!
      end
    end
  end

  test "it raises an error if an email cannot be sent via notify in Production" do
    raises_exception = lambda { |_author, _edition, _edition_admin_url, _public_document_url|
      response = Minitest::Mock.new
      ENV["SENTRY_CURRENT_ENV"] = "production"
      response.expect :code, 400
      response.expect :body, "Can't send to this recipient using a team-only API key"
      raise Notifications::Client::BadRequestError, response
    }

    MailNotifications.stub(:edition_published, raises_exception) do
      ActionMailer::Base.deliveries.clear
      edition = create(:edition)
      assert_raises do
        AuthorNotifierService.new(edition).notify!
      end
    end
  end
end
