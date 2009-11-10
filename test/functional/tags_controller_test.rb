require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  setup :activate_authlogic

  setup do
    ActsAsChangelogable::Session.begin
  end

  teardown do
    ActsAsChangelogable::Session.end
  end

  context "index action" do
    context "index action NOT logged in" do
      should_redirect_to "login url" do
        get :index
        new_user_session_url
      end
    end

    should "render index template" do
      login_as_admin
      get :index
      assert_template 'index'
      assert Tag.new.search(""), assigns(:tags)
    end

    should "display a debug of the SQL if a debug param is passed" do
      login_as_admin
      get :index, :debug => "true"
      assert_template 'index'
      assert_equal "<span style='font-size:smaller'>SQL: #{Tag.new.search_sql("").inspect}</span>", flash[:notice]
    end

    context "filtering" do
      should "filter the tags by the specified criteria and redisplay the list of tags" do
        login_as_admin
        get :index, params = {:size => "728x90", :network_id => "1", :include_disabled => "", :publisher_id =>"1"}
        assert_equal Tag.new.search(params), assigns(:tags)
        assert_template 'index'
      end

      should "remember the filter fields to the session" do
        login_as_admin
        get :index, params = {:size => size = "728x90", :network_id => network_id = "1",
                              :name_search => name_search = "foo", :include_disabled => include_disabled = "",
                              :publisher_id => publisher_id = "1"}

        assert_not_nil session[:tag_params]
        assert size, session[:tag_params][:size]
        assert network_id, session[:tag_params][:network_id]
        assert name_search, session[:tag_params][:name_search]
        assert include_disabled, session[:tag_params][:include_disabled]
        assert publisher_id, session[:tag_params][:publisher_id]
      end

      should "use the session filter fields in the view if none provided" do
        login_as_admin
        session[:tag_params] = {:name_search => name_search = "Cool Name Search"}
        get :index
        assert @response.body.include?(name_search)
      end

      should "apply the session filter fields to the search if none provided" do
        login_as_admin
        session[:tag_params] = params = {:size => "728x90", :network_id => "1", :include_disabled => "", :publisher_id =>"1"}
        get :index
        assert_equal Tag.new.search(params), assigns(:tags)
      end

      should "display a flash warning if no tags were found from the filter criteria" do
        login_as_admin
        get :index, :size => "bogus_size"
        assert_equal "No matching tags found", flash[:warning]
        assert_template 'index'
      end
    end
  end

  context "show action" do
    should "render show template" do
      login_as_admin
      get :show, :id => Tag.first
      assert_template 'show'
    end
  end

  context "new action" do
    should "render new template" do
      login_as_admin
      get :new
      assert_redirected_to "/tags/select_network"
    end
  end

  context "create action" do
    context "NOT logged in" do
      should_redirect_to "login url" do
        post :create
        new_user_session_url
      end
    end

    context "successful create" do
      setup do
        @admin_user = login_as_admin

        post :create, {"tag"=>{"sample_rate"=>"", "size"=>"728x90", "network_id"=>"2", "tag"=>"", "frequency_cap"=>"",
                               "tier"=>"10", "tag_targets_attributes"=>{"0"=>{"key_name"=>"country", "id"=>"", "key_value"=>""}},
                               "rejection_time"=>"", "enabled"=>"true", "value"=>"1.00", "tag_name"=>"Scotts Tag",
                               "tag_options_attributes"=>{"0"=>{"option_name"=>"", "option_value"=>""}}, "always_fill"=>"false",
                               "publisher_id"=>"1045"}, "note"=>{"tag"=>""}, "tag_toggle"=>"template"}

        @new_tag = Tag.find_by_tag_name("Scotts Tag")
      end

      should "create a new tag and redirect to it's show page" do
        assert_redirected_to tag_path(@new_tag)
      end

      should "add an entry into the changelogs with the currently logged in user and a polymorphic association back to original" do
        changelog = ActsAsChangelogable::Changelog.find_by_user_id(@admin_user.id)
        assert changelog
        assert_equal Tag, changelog.record.class
        assert_equal @new_tag, changelog.record
      end
    end
  end

  context "edit action" do
    should "render edit template" do
      login_as_admin
      get :edit, :id => Tag.first
      assert_template 'edit'
    end
  end

  context "update action" do
    should "render edit template when model is invalid" do
      login_as_admin
      Tag.any_instance.stubs(:valid?).returns(false)
      put :update, :id => Tag.first
      assert_template 'edit'
    end

    should "redirect to list when model is valid" do
      login_as_admin
      Tag.any_instance.stubs(:valid?).returns(true)
      put :update, :id => Tag.first
      assert_redirected_to tags_url
    end
  end

  context "destroy action" do
    should "destroy model and redirect to index action" do
      login_as_admin
      tag = Tag.first
      delete :destroy, :id => tag
      assert_redirected_to tags_url
      assert !Tag.exists?(tag.id)
    end
  end

end
