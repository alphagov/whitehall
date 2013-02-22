require "test_helper"

class LocalisedUrlPathHelperTest < ActiveSupport::TestCase
  test "should call original news_article_path with locale set" do
    controller = FakeController.new(locale: "fr")
    object = stub('news article')
    controller.expects(:news_article_path_was_called).with(object, locale: "fr")
    controller.news_article_path(object)
  end

  test "should not generate paths including locale with en locale set" do
    controller = FakeController.new(locale: "en")
    object = stub('news article')
    controller.expects(:news_article_path_was_called).with(object, {})
    controller.news_article_path(object)
  end

  module FakeRouting
    def news_article_path(object, options={})
      news_article_path_was_called(object, options)
    end

    def news_article_path_was_called(object, options={})
    end
  end

  class FakeController
    attr_reader :params
    def initialize(params={})
      @params = params
    end

    include FakeRouting
    include LocalisedUrlPathHelper
  end
end
