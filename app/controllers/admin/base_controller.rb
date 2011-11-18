class Admin::BaseController < ApplicationController
  include AdminDocumentRoutesHelper

  layout 'admin'
  before_filter :authenticate!
  before_filter :skip_slimmer
end
