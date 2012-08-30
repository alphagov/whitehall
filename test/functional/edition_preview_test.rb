# encoding: utf-8

require "test_helper"

class EditionPreviewTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper
  default_url_options[:host] = 'test.host'
end
