class Admin::BaseController < ApplicationController
  include Admin::EditionRoutesHelper

  layout 'admin'
  before_filter :authenticate_user!
  before_filter :skip_slimmer
end
