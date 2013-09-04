# == Schema Information
#
# Table name: mainstream_links
#
#  id            :integer          not null, primary key
#  url           :string(255)
#  title         :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  linkable_type :string(255)
#  linkable_id   :integer
#

class MainstreamLink < ActiveRecord::Base
  belongs_to :linkable, polymorphic: true

  validates :url, :title, presence: true
  validates :url, uri: true

  DEFAULT_INITIAL_SET_SIZE = 5

  def self.only_the_initial_set(set_size = MainstreamLink::DEFAULT_INITIAL_SET_SIZE)
    limit(set_size)
  end
end
