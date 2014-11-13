
BksOnRails::Application.routes.draw do

  root 'static_pages#home'

  match '/sign_in', to:'sessions#new', via: 'get'
  match '/sign_out', to:'sessions#destroy', via: 'delete' 
  match '/manual', to: 'static_pages#manual', via: 'get'

  resources :sessions, only: [:new, :create, :destroy]

  # resources :accounts

  # resources :contacts

  resources :staffers do
    resource :account, only: [:new, :create, :edit, :update]
    resource :contact, only: [:new, :create, :edit, :update]
  end

  resources :managers do
    resource :account, only: [:new, :create, :edit, :update]
    resource :contact , only: [:new, :create, :edit, :update] 
  end

  resources :riders do
    resource :account, only: [:new, :create, :edit, :update]
    resource :location, only: [:new, :create, :edit, :update]
    resource :rider_rating, only: [:new, :create, :edit, :update]
    resource :qualification_set, only: [:new, :create, :edit, :update]
    resource :skill_set, only: [:new, :create, :edit, :update]
    resource :equipment_set, only: [:new, :create, :edit, :update]
    resources :assignments
    resources :shifts do
      resources :assignments
    end
    resource :toe_consent, only: [:new, :create, :complete]
    resources :conflicts
    collection do 
      get :export, :edit_statuses
      put :update_statuses 
    end
  end


  resources :restaurants do
    resource :mini_contact, only: [:new, :create, :edit, :update]
    resources :managers, only: [:new, :create, :edit, :update, :show, :destroy]
      resource :account, only: [:new, :create, :edit, :update]
        # resource :contact, only: [:new, :create, :edit, :update]
    resource :work_specification, only: [:new, :create, :edit, :update]
    resource :rider_payment_info, only: [:new, :create, :edit, :update]
    resource :agency_payment_info, only: [:new, :create, :edit, :update]
    resource :equipment_set, only: [:new, :create, :edit, :update]
    resources :shifts do
      resources :assignments
    end
    collection { get :export }
  end

  resources :shifts do
    resources :assignments
    collection { get :export, :build_export, :unconfirmed, :unconfirmed_next_week, :today, :review_points }
  end

  post 'shifts/index'
  post 'restaurants/:id/shifts/index' => 'shifts#index'
  post 'riders/:id/shifts/index' => 'shifts#index'

  # grid routes
  get "grid/shifts"
  match '/shift_grid', to: 'grid#shifts', via: 'get'
  get "grid/availability"
  match '/availability_grid', to: 'grid#availability', via: 'get'
  post "grid/send_emails" => 'grid#send_emails'

  # non-resourceful shift routes
  get 'shift/hanging' => 'shifts#hanging'
  get 'shift/clone_new' => 'shifts#clone_new' 
  get 'shift/batch_new' => 'shifts#batch_new'
  post 'shift/batch_create' => 'shifts#batch_create'
  get 'shift/batch_edit' => 'shifts#batch_edit'
  post 'shift/batch_edit' => 'shifts#batch_update'
  get 'shift/build_clone_week_preview' => 'shifts#build_clone_week_preview'
  get 'shift/preview_clone_week' => 'shifts#preview_clone_week'
  post 'shift/save_clone_week' => 'shifts#save_clone_week'
  
  #non-resources assignment routes
  get 'assignment/batch_edit' => 'assignments#batch_edit'
  post 'assignment/batch_edit' => 'assignments#batch_update'
  get 'assignment/batch_edit_uniform' => 'assignments#batch_edit_uniform'
  post 'assignment/batch_edit_uniform' => 'assignments#batch_update_uniform'
  get 'assignment/resolve_obstacles' => 'assignments#request_obstacle_decisions'
  post 'assignment/resolve_obstacles' => 'assignments#resolve_obstacles'
  post 'assignment/batch_reassign' => 'assignments#batch_reassign'

  # non-resourceful conflict routes 
  get 'conflict/build_batch_preview' => 'conflicts#build_batch_preview'
  get 'conflict/preview_batch' => 'conflicts#preview_batch'
  post 'conflict/batch_clone' => 'conflicts#batch_clone'
  get 'conflict/batch_new' => 'conflicts#batch_new'
  post 'conflict/batch_new' => 'conflicts#batch_create'
  get 'conflict/confirm_submission' => 'conflicts#confirm_submission'

  # non-resourcesful rider routes
  get 'rider/request_conflicts_preview' => 'riders#request_conflicts_preview'
  get 'rider/request_conflicts' => 'riders#request_conflicts'
  get 'riders/:rider_id/toe_consent/complete' => 'toe_consents#complete'  


  # post 'riders/:id/batch_clone_conflicts' => 'riders#batch_clone_conflicts'
  # get 'riders/:id/batch_new_conflicts' => 'riders#batch_clone_conflicts'
  # post 'riders/:id/batch_new_conflicts' => 'riders#batch_clone_conflicts'

  
  resources :conflicts





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
