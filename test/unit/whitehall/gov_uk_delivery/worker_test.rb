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

    end
  end
end
