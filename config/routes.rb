ActionController::Routing::Routes.draw do |map|

  map.feedback 'feedbacks', :controller => 'feedbacks', :action => 'create'
  map.new_feedback 'feedbacks/new', :controller => 'feedbacks', :action => 'new'

  # The priority is based upon order of creation: first created -> highest priority.
  #
  map.resource :account, :controller => "users"
  map.resources :ad_formats
  map.resources :changelogs
  map.resources :comments
  map.javascript_errors_by 'javascript_errors/grouped_by/:field', :controller => 'javascript_errors', :action => 'grouped_by'
  map.resources :javascript_errors
  map.resources :movers
  map.resources :networks, :has_many => :network_tag_options
  map.publisher_ad_formats 'publishers/ad_formats', :controller => 'publishers', :action => 'ad_formats'
  map.publisher_save_ad_formats 'publishers/save_ad_formats', :controller => 'publishers', :action => 'save_ad_formats'
  map.publisher_quality_control 'publishers/quality_control', :controller => 'publishers', :action => 'quality_control'
  map.publisher_site_info 'publishers/site_info', :controller => 'publishers', :action => 'site_info'
  map.resources :publishers, :has_many => :tags
  map.resources :publisher_network_logins
  map.resources :publisher_tags
  map.resources :password_resets
  map.revenue_index_results 'revenues/index_results', :controller => 'revenues', :action => 'index_results'
  map.revenue_index_results 'revenues/bulk_update', :controller => 'revenues', :action => 'bulk_update'
  map.resources :revenues
  map.resources :tag_targets

  # FIXME: I've tried to add these two as :member => {:new_change_password => :get, :change_password => :put} on the
  # map.resources :users with no luck. - SJT
  map.new_change_password_user '/users/:id/new_change_password', :controller => 'users', :action => 'new_change_password'
  map.change_password_user '/users/:id/change_password', :controller => 'users', :action => 'change_password', :method => 'put'

  # FIXME: Is there way to not have to list all these?
  map.select_network 'tags/select_network', :controller => 'tags', :action => 'select_network'
  map.tag_generator  'tags/generator/:id', :controller => 'tags', :action => 'generator'
  map.tag_html_preview  'tags/html_preview', :controller => 'tags', :action => 'html_preview'
  map.tag_copy  'tags/copy/:id', :controller => 'tags', :action => 'copy'
  map.resources :tags, :has_many => [ :ad_formats, :tag_options, :tag_targets ]
  map.resource :user_session
  map.resources :users

  # Charts
  map.chart_misc 'charts/misc/:stat', :controller => 'charts', :action => "misc_stat"
  map.chart 'charts/:id/:action', :controller => 'charts'

  # Data export
  map.data_export 'data_export', :controller => 'data_export'
  map.create_data_export 'data_export/create', :controller => 'data_export', :action => "create"

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "homes"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
