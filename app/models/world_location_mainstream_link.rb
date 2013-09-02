# == Schema Information
#
# Table name: world_location_mainstream_links
#
#  id                 :integer          not null, primary key
#  world_location_id  :integer
#  mainstream_link_id :integer
#

class WorldLocationMainstreamLink < ActiveRecord::Base
  belongs_to :mainstream_link
  belongs_to :world_location
end
