require 'test_helper'

class HashSyntaxTest < ActiveSupport::TestCase

  IGNORED_FILES = %w(db/schema.rb app/uploaders/attachment_uploader.rb)

  test "should only allow Ruby v1.9 Hash syntax" do
    files = Dir["#{Rails.root}/**/{*.rb,Gemfile}"]
    naughty_files = []
    files.each do |filename|
      relative_file = filename.gsub(%r{#{Rails.root}/}, "")
      next if IGNORED_FILES.include?(relative_file)
      original_file = File.read(filename)
      transformed_file = HashSyntax::Transformer.transform(original_file, :"to-19" => true)
      unless original_file == transformed_file
        naughty_files << relative_file
      end
    end
    message = "Files using Ruby v1.8 Hash syntax :-\n%s\n%s" % [naughty_files.join("\n"), "You might want to run `bundle exec hash_syntax --to-19 [paths]` to fix the offending files."]
    assert naughty_files.empty?, message
  end
end
