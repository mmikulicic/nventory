ActionController::Routing::Routes.draw do |map|
  map.resources :accounts,                          :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :comments
  map.resources :database_instance_relationships,                                                             :member => { :version_history => :get }
  map.resources :database_instances,                :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :datacenter_rack_assignments,                                                                 :member => { :version_history => :get }
  map.resources :datacenter_vip_assignments,                                                                  :member => { :version_history => :get }
  map.resources :datacenters,                       :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :hardware_profiles,                 :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :ip_addresses,                      :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :network_interfaces,                :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :node_database_instance_assignments,                                                          :member => { :version_history => :get }
  map.resources :node_group_node_assignments,                                                                 :member => { :version_history => :get }
  map.resources :node_group_node_group_assignments,                                                           :member => { :version_history => :get }
  map.resources :node_groups,                       :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :nodes,                             :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :operating_systems,                 :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :outlets,                           :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :rack_node_assignments,                                                                       :member => { :version_history => :get }
  map.resources :racks,                             :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :statuses,                          :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :subnets,                           :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }
  map.resources :vips,                              :collection => { :field_names => :get, :search => :get }, :member => { :version_history => :get }

  # add get method that will return the consumer on this outlet (used in AJAX on Node page)
  map.resources :outlets, :member => { :consumer => :get } 
  
  # add get method that will return the visualization of this rack
  map.resources :racks,       :member => { :visualization => :get } 
  map.resources :datacenters, :member => { :visualization => :get } 

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "dashboard"
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
