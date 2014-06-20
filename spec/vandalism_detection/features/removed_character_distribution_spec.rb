require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedCharacterDistribution do

  before do
    @feature = Wikipedia::VandalismDetection::Features::RemovedCharacterDistribution.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the Kullback-Leibler Divergence of the removed text's character distribution" do
      old_text = Wikipedia::VandalismDetection::Text.new 'old text [[new inserted text]] given dero 9'
      new_text = Wikipedia::VandalismDetection::Text.new('old text')

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 1.6609633564650683
    end

    it "returns maximum float value if no alphanumeric characters are removed" do
      old_text = Wikipedia::VandalismDetection::Text.new("old text !* [[?]]")
      new_text = Wikipedia::VandalismDetection::Text.new("old text")

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == Float::MAX
    end

    it "returns Infinity if no text inserted" do
      old_text = Wikipedia::VandalismDetection::Text.new("text")
      new_text = Wikipedia::VandalismDetection::Text.new("deletion text")

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == Float::MAX
    end
  end
end