require 'spec_helper'

describe Wikipedia::VandalismDetection::Edit do

  before do
    @old_revision = build :old_revision
    @new_revision = build :new_revision

    @edit = Wikipedia::VandalismDetection::Edit.new(@old_revision, @new_revision)
  end

  it "has an old revision" do
    @edit.old_revision.should == @old_revision
  end

  it "has a new revision" do
    @edit.new_revision.should == @new_revision
  end

  describe "exception handling" do
    it "raises no error if revisions are not sequent" do
      expect { Wikipedia::VandalismDetection::Edit.new(@old_revision, @new_revision) }.not_to raise_error
    end

    it "raises an error if revisions are not sequent" do
      expect { Wikipedia::VandalismDetection::Edit.new(@new_revision, @old_revision) }.to raise_exception ArgumentError
    end
  end

  describe "#serialize" do
    it "serializes the given parameters into a string" do
      @edit.serialize(:id, :text).should == "1:text 1\t2:text 2"
    end
  end

  describe "#inserted_words" do
    it "returns the inserted words as array" do
      old_revision = build(:old_revision, text: "")
      new_revision = build(:new_revision, text: "inserted words")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      edit.inserted_words.should == ['inserted', 'words']
    end

    it "returns the uncleaned text inserted words as array" do
      old_revision = build(:old_revision, text: "")
      new_revision = build(:new_revision, text: "[[inserted words]]")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      edit.inserted_words.should == ['[[inserted', 'words]]']
    end
  end

  describe "#inserted_text" do
    it "returns the inserted text as Wikipedia::VandalismDetection::Text" do
      old_revision = build(:old_revision, text: "")
      new_revision = build(:new_revision, text: "inserted words")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      edit.inserted_text.should == Wikipedia::VandalismDetection::Text.new('inserted words')
    end

    it "returns the uncleaned text inserted text as Wikipedia::VadalismDetection::Text" do
      old_revision = build(:old_revision, text: "")
      new_revision = build(:new_revision, text: "[[inserted words]]")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      edit.inserted_text.should == Wikipedia::VandalismDetection::Text.new('[[inserted words]]')
    end
  end
end