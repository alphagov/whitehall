class Admin::BaseController < ApplicationController
  include Admin::DocumentRoutesHelper

  layout 'admin'
  before_filter :authenticate_user!
  before_filter :skip_slimmer
end
