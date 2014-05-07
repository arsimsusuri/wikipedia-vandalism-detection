FactoryGirl.define do
  factory :empty_revision, class: Wikipedia::VandalismDetection::Revision do |f|
    f.id nil
    f.parent_id nil
    f.timestamp nil
    f.text Wikipedia::VandalismDetection::Text.new
    f.comment Wikipedia::VandalismDetection::Text.new
  end

  factory :old_revision, class: Wikipedia::VandalismDetection::Revision do |f|
    f.id '1'
    f.parent_id nil
    f.timestamp nil
    f.text Wikipedia::VandalismDetection::Text.new('text 1')
    f.comment Wikipedia::VandalismDetection::Text.new
  end

  factory :new_revision, class: Wikipedia::VandalismDetection::Revision do |f|
    f.id '2'
    f.parent_id '1'
    f.timestamp '2014-11-27T18:00:00Z'
    f.text Wikipedia::VandalismDetection::Text.new('text 2')
    f.comment Wikipedia::VandalismDetection::Text.new
  end

  factory :anonymous_revision, class: Wikipedia::VandalismDetection::Revision do |f|
    f.id '2'
    f.parent_id '1'
    f.timestamp '2014-11-27T18:00:00Z'
    f.text Wikipedia::VandalismDetection::Text.new('text 2')
    f.comment Wikipedia::VandalismDetection::Text.new
    f.contributor '127.0.0.1'
  end

  factory :registered_revision, class: Wikipedia::VandalismDetection::Revision do |f|
    f.id '2'
    f.parent_id '1'
    f.timestamp '2014-11-27T18:00:00Z'
    f.text Wikipedia::VandalismDetection::Text.new('text 2')
    f.comment Wikipedia::VandalismDetection::Text.new
    f.contributor '12345'
  end
end