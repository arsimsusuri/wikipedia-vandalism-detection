require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::VulgarismFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::VulgarismFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::FrequencyBase }

  describe "#calculate" do

    it "returns the number of vulgarism words relative to all words count" do
      # total 10 words, 3 vulgarism
      text = Wikipedia::VandalismDetection::Text.new 'Fuck you, fu*ck you $lut, you and all the others'

      old_revision = build(:old_revision)
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 3.0/10.0
    end

    it "returns 0.0 on emtpy clean text revisions" do
      text = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"

      old_revision = build(:old_revision, text: text)
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.0
    end
  end
end