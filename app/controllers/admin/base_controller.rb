class Admin::BaseController < ApplicationController
  include AdminDocumentRoutesHelper

  layout 'admin'
  before_filter :authenticate!
end
