module SpeechesTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_render_a_list_of_speeches
      test "index links to published speeches" do
        speech = create(:published_speech, title: "speech-title")
        get :index
        assert_select "#speeches" do
          assert_select_object speech do
            assert_select "a[href=#{speech_path(speech.document_identity)}]"
            assert_select ".title", text: "speech-title"
          end
        end
      end

      test "index excludes unpublished speeches" do
        speech = create(:draft_speech)
        get :index
        assert_select_object speech, count: 0
      end

      test "index lists newest speeches first" do
        oldest_speech = create(:published_speech, title: 'oldest', published_at: 4.hours.ago)
        newest_speech = create(:published_speech, title: 'newest', published_at: 2.hours.ago)
        get :index
        assert_equal [newest_speech, oldest_speech], assigns[:speeches]
      end

      test "index doesn't display an empty list if there aren't any speeches" do
        get :index
        assert_select "#speeches ul", count: 0
      end
    end
  end
end
  