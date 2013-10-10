require 'test_helper'

class SpeechTypeTest < ActiveSupport::TestCase
  test 'search_format_types tags the type with the singular name, prefixed with speech-' do
    SpeechType.all.each do |speech_type|
      assert speech_type.search_format_types.include?('speech-'+speech_type.singular_name.parameterize)
    end
  end

  test 'search_format_types tags the type with the speech-statement-to-parliament if the type is a statement' do
    SpeechType.statements.each do |speech_type|
      assert speech_type.search_format_types.include?('speech-statement-to-parliament')
    end
    SpeechType.non_statements.each do |speech_type|
      refute speech_type.search_format_types.include?('speech-statement-to-parliament')
    end
  end

end
