namespace :block_editor do
  desc "Build JS and CSS assets"
  task build: :environment do
    Dir.chdir(Rails.root.join("block-editor")) {
      sh "npm run build"
    }
  end
end
