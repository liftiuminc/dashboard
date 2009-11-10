require 'test_helper'

class TagTargetTest < ActiveSupport::TestCase
  setup do
    ActsAsChangelogable::Session.begin
  end

  teardown do
    ActsAsChangelogable::Session.end
  end

  should_acts_as_changelogable do
    tag = Tag.find(:first)
    TagTarget.create!(:tag_id => tag.id, :key_name => "key", :key_value => "value")
  end

end
