GreenLockers::Application.routes.draw do
  root :to => "pages#index"
  post "api/DoorOpened(.:format)" => "api#DoorOpened"
  post "api/DropOff(.:format)"
  post "api/SyncAccessInfo(.:format)"
  post "api/SyncOperatorInfo(.:format)"
  post "api/SyncAdminInfo(.:format)"
  post "api/BarcodeNotExist(.:format)"
  post "api/BoxIntruded(.:format)"
  
  post "boxes/assign"
  post "boxes/assign_backup"
  post "boxes/reassign"
  post "boxes/reassign_backup"
  post "boxes/delivered"
  post "boxes/picked_up"
  post "boxes/dropped_off"
  post "boxes/received"
  post "boxes/:id/open", to: "boxes#open", as: "open_box"
  
  post "lockers/:id/sync", to: "lockers#sync", as: "sync_locker"
  
  post "employees/set_permissions"
  post "employees/set_privileges"
  
  resources :lockers

  resources :employees

  resources :trackings

  resources :packages

  resources :branches

  resources :boxes

  resources :users
  
  get "logs" => "loggings#index"
  get "logs/box/:id", to: "loggings#box_logs", as: "box_logs"
  get "logs/package/:id", to: "loggings#package_logs", as: "package_logs"
  get "packages/:id/get_available_boxes" => "packages#get_available_boxes"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
