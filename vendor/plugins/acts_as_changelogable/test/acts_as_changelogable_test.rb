require 'test_helper'

class TestModel < ActiveRecord::Base
  acts_as_changelogable
end

class TestNoChangelogModel < ActiveRecord::Base
end

class ActsAsChangelogableTest < ActiveSupport::TestCase
  setup do
    Changelog.delete_all
  end

  test "it can be created" do
    assert TestModel.new
  end

  test "it does not create an entry in the changelog if acts_as_changelogable is not included" do
    assert_changes(Changelog, 0) do
      TestNoChangelogModel.create(:name => "foo")
    end
  end

  test "it creates an entry in the changlogs table when it's saved if acts_as_changelogable is included" do
    assert_changes(Changelog) do
      TestModel.create(:name => "foo")
    end
  end

  test "it fills in the Changelog entry with deets on create" do
    test_model = TestModel.create(:name => "foo")
    changelog = Changelog.find(:first)
    assert_equal test_model.id, changelog.record_id
    assert_equal test_model.class.to_s, changelog.record_type
    assert_nil   changelog.user_id
    assert_equal "create", changelog.operation
    assert_match "TestModel created at", changelog.description
    assert_match "{\"name\":[null,\"foo\"],", changelog.diff
    assert_match "\"created_at\":[null,", changelog.diff
    assert_match "\"updated_at\":[null,", changelog.diff
    assert_match "\"id\":[null,#{test_model.id}]}", changelog.diff
  end

  test "it fills in the Changelog entry with deets on update" do
    test_model = TestModel.create(:name => "foo")
    test_model.reload.update_attribute(:name, "bar")
    changelog = Changelog.find(:last)
    assert_equal "update", changelog.operation
    assert_match "TestModel updated at", changelog.description
    assert_match "{\"name\":[\"foo\",\"bar\"]", changelog.diff
    assert_match "\"updated_at\":", changelog.diff
  end

  test "it fills in the Changelog entry with deets on destroy" do
    test_model = TestModel.create(:name => "foo")
    test_model.destroy
    changelog = Changelog.find(:last)
    assert_equal "destroy", changelog.operation
    assert_match "TestModel destroyd at", changelog.description
  end
end

def assert_changes(klass, amount = 1)
  before_count = klass.count
  yield
  assert_equal before_count + amount, klass.count
end
