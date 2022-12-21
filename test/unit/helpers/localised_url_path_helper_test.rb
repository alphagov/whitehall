require "test_helper"

class LocalisedUrlPathHelperTest < ActiveSupport::TestCase
  test "should not generate paths including locale with en locale set" do
    controller = FakeController.new(locale: "en")
    object = stub("news article")
    object.stubs(:available_in_locale?).returns(true)
    controller.expects(:news_article_path_was_called).with(object, {})
    controller.news_article_path(object)
  end

  test "should not generate paths include locale when target object is not available in that locale" do
    controller = FakeController.new(locale: "fr")
    object = stub("news article")
    object.stubs(:available_in_locale?).with("fr").returns(false)
    controller.expects(:news_article_path_was_called).with(object, {})
    controller.news_article_path(object)
  end

  test "should generate paths including locale for nested models" do
    controller = FakeController.new(locale: "fr")
    parent = stub("parent resource")
    object = stub("coporate_information_page")
    object.stubs(:available_in_locale?).with("fr").returns(true)
    controller.expects(:worldwide_organisation_corporate_information_page_path_was_called).with(parent, object, { locale: "fr" })
    controller.worldwide_organisation_corporate_information_page_path(parent, object)
  end

  module FakeRouting
    def news_article_path(object, options = {})
      news_article_path_was_called(object, options)
    end

    def news_article_path_was_called(object, options = {}); end

    def worldwide_organisation_corporate_information_page_path(parent, page, options = {})
      worldwide_organisation_corporate_information_page_path_was_called(parent, page, options)
    end

    def worldwide_organisation_corporate_information_page_path_was_called(parent, page, options = {}); end
  end

  class FakeController
    attr_reader :params

    def initialize(params = {})
      @params = params
    end

    include FakeRouting
    include LocalisedUrlPathHelper
  end
end
