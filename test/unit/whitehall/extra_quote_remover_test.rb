# encoding: UTF-8
# *NOTE* this file deliberately does not include test_helper
# in order to attempt to speed up the tests

require File.expand_path("../../../fast_test_helper", __FILE__)
require 'whitehall/extra_quote_remover'

module Whitehall
  class ExtraQuoteRemoverTest < ActiveSupport::TestCase
    def assert_remover_transforms(options)
      from = options.keys.first
      to = options.values.first
      assert_equal to, ExtraQuoteRemover.new.remove(from)
    end

    def assert_leaves_untouched(candidate)
      assert_remover_transforms candidate => candidate
    end

    test "ignores nil" do
      assert_leaves_untouched nil
    end

    test "ignores text without double quotes" do
      assert_leaves_untouched %{no quotes\na few lines,\n\n\n\nbut no quotes\n\n}
    end

    test "ignores text without a quote symbol" do
      assert_leaves_untouched %{quotes\n"but not with a > symbol"}
    end

    test "transforms text with surrounding quotes" do
      assert_remover_transforms(
        %{He said:\n> "yes, it's true!"\n\napparently.} =>
        %{He said:\n> yes, it's true!\n\napparently.}
      )
    end

    test "leaves quotes in the middle of the string" do
      assert_remover_transforms(
        %{He said:\n> "yes, it's true!" whilst sipping a cocktail. "And yes, I did rather enjoy it." \n\napparently.} =>
        %{He said:\n> yes, it's true!" whilst sipping a cocktail. "And yes, I did rather enjoy it.\n\napparently.}
      )
    end

    test "leaves trailing text and quote intact" do
      assert_remover_transforms(
        %{He said:\n> "yes, it's true!" whilst sipping a cocktail.} =>
        %{He said:\n> yes, it's true!" whilst sipping a cocktail.}
      )
    end

    test "windows line breaks" do
      assert_remover_transforms(
        %{Sir George Young MP, said\r\n>  "I welcome the positive public response to the e-petitions site, which is important way of building a bridge between people and Parliament.”\r\n## The special relationship} =>
        %{Sir George Young MP, said\r\n> I welcome the positive public response to the e-petitions site, which is important way of building a bridge between people and Parliament.\r\n## The special relationship}
      )
    end

    test "no space in front" do
      assert_remover_transforms(
        %{>"As we continue with the redundancy process we will ensure we retain the capabilities that our armed forces will require to meet the challenges of the future. The redundancy programme will not impact adversely on the current operations in Afghanistan, where our armed forces continue to fight so bravely on this country's behalf."} =>
        %{> As we continue with the redundancy process we will ensure we retain the capabilities that our armed forces will require to meet the challenges of the future. The redundancy programme will not impact adversely on the current operations in Afghanistan, where our armed forces continue to fight so bravely on this country's behalf.}
      )
    end

    test "remove double double quotes" do
      assert_remover_transforms(
        %{We heard it said:\n\n> ""Today the coalition is remedying those deficiencies by putting in place a new fast track process where the people's elected representatives have responsibility for the final decisions about Britain's future instead of unelected commissioners.""} =>
        %{We heard it said:\n\n> Today the coalition is remedying those deficiencies by putting in place a new fast track process where the people's elected representatives have responsibility for the final decisions about Britain's future instead of unelected commissioners.}
      )
      assert_remover_transforms(
        %{> ""Today the coalition is remedying those deficiencies by putting in place a new fast track process where the people's elected representatives have responsibility for the final decisions about Britain's future instead of unelected commissioners.} =>
        %{> Today the coalition is remedying those deficiencies by putting in place a new fast track process where the people's elected representatives have responsibility for the final decisions about Britain's future instead of unelected commissioners.}
      )
    end

    test "removes quotes correctly from multi-line blockquotes" do
      assert_remover_transforms(
        %{> "Here is a block quote using 2 lines and two of the arrows.\n> I am not sure how this will render.  I think it will mash them together."} =>
        %{> Here is a block quote using 2 lines and two of the arrows.\n> I am not sure how this will render.  I think it will mash them together.}
      )
    end

    test "preserves multiline blockquotes with plain newlines quotes" do
      text = %{> "I was so very sorry to hear of the deaths of these five brave soldiers, killed in the course of their duties in Afghanistan. That they were killed by one of those they were working alongside is a particular tragedy.> \n> "The memory of WO1 (RSM) Darren Chant, Sgt Matthew Telford, Cpl Nicholas Webster-Smith, Cpl Steven Boote and Guardsman James Major will live on. They were men of courage who died building security in Afghanistan and protecting people in the UK from terrorism.\n> \n> "My deepest sympathies and condolences lie with their grieving families, friends, and all those who served alongside them, who will feel the pain of loss most intensely. They are in all our thoughts."}
      assert_remover_transforms(
        text =>
        %{> I was so very sorry to hear of the deaths of these five brave soldiers, killed in the course of their duties in Afghanistan. That they were killed by one of those they were working alongside is a particular tragedy.\n> \n> The memory of WO1 (RSM) Darren Chant, Sgt Matthew Telford, Cpl Nicholas Webster-Smith, Cpl Steven Boote and Guardsman James Major will live on. They were men of courage who died building security in Afghanistan and protecting people in the UK from terrorism.\n> \n> My deepest sympathies and condolences lie with their grieving families, friends, and all those who served alongside them, who will feel the pain of loss most intensely. They are in all our thoughts.}
        )
    end

    test "preserve newlines when there's a blockquote with additional text after" do
      text = %{> \n> blah}
      assert_remover_transforms(
        text => text
      )
    end
  end
end
