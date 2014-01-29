# encoding: utf-8
require 'test_helper'

module Whitehall
  module GovUkDelivery
    class WorkerTest < ActiveSupport::TestCase

      test ".notify! performs the job asynchronously with the given arguments" do
        edition = create(:published_policy)
        notification_date = Time.zone.now
        title = "Example title"
        summary = "Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Maecenas sed diam eget risus varius blandit sit amet non magna."

        Worker.expects(:perform_async).with(edition.id, notification_date.iso8601, {title: title, summary: summary})
        Worker.notify!(edition, notification_date, title, summary)
      end

      test '#perform swallows API 400 errors (i.e. no subscribers)' do
        Whitehall.govuk_delivery_client.expects(:notify).raises(GdsApi::HTTPErrorResponse, 400)
        assert_nothing_raised { perform }
      end

      test '#perform does not rescue non-400 API errors' do
        Whitehall.govuk_delivery_client.expects(:notify).raises(GdsApi::HTTPErrorResponse, 500)
        exception = assert_raise(GdsApi::HTTPErrorResponse) { perform }
        assert_equal 500, exception.code
      end

      test '#perform does not rescue any other non-API errors' do
        Whitehall.govuk_delivery_client.expects(:notify).raises(RuntimeError)
        exception = assert_raise(RuntimeError) { perform }
      end

    private

      def perform
        edition = create(:edition)
        Worker.new.perform(edition.id, Date.today.iso8601, {})
      end

    end
  end
end
