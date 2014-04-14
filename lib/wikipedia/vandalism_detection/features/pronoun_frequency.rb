require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/pronouns'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the frequency of pronouns in the text of the new revision.
      class PronounFrequency < FrequencyBase

        # Returns the percentage of pronoun words in the new revision's text.
        # Returns 0.0 if text is of zero length.
        def calculate(edit)
          super

          text = edit.new_revision.text.clean
          frequency(text, WordLists::PRONOUNS)
        end
      end
    end
  end
end