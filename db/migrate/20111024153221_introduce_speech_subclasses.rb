class IntroduceSpeechSubclasses < ActiveRecord::Migration
  def change
    update %{UPDATE documents SET type = 'Speech::Transcript' WHERE type = 'Speech'}
  end
end
