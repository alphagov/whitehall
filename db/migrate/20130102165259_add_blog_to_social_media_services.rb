class AddBlogToSocialMediaServices < ActiveRecord::Migration
  def change
    SocialMediaService.create(name: "Blog")
  end
end
