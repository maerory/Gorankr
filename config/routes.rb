Rails.application.routes.draw do
  #resources :posts
  root 'users#index'
  
   # Chat room routing
  post '/chat_rooms/:id/join' => "chat_rooms#user_admit_room", as: 'join_chat_room'
  post '/chat_rooms/:id/chat' => "chat_rooms#chat", as: "chat_chat_room"
  delete '/chat_rooms/:id/exit' => "chat_rooms#user_exit_room", as: "exit_chat_room"
  get '/chat_rooms' => "chat_rooms#index", as: 'chat_rooms'
  post '/chat_rooms' => 'chat_rooms#create'
  get '/chat_rooms/new' => 'chat_rooms#new', as: 'new_chat_room'
  get '/chat_rooms/:id/edit' => 'chat_rooms#edit', as: 'edit_chat_room'
  get '/chat_rooms/:id' => 'chat_rooms#show', as: 'chat_room'
  delete '/chat_rooms/:id' => 'chat_rooms#destroy'

  # Routing for user menus
  get '/index' => 'users#index'
  get '/sign_up' => 'users#sign_up'
  get '/sign_in' => 'users#sign_in'
  post '/sign_up' => 'users#user_sign_up'
  post '/sign_in' => 'users#user_sign_in'
  delete '/sign_out' => 'users#sign_out'
  get '/:user_name' => 'users#user_info', as: 'user_info'
  get '/:user_name/edit' => 'users#edit', as: 'user_edit'
  get '/:user_name/link' => 'users#game_link', as: 'game_link'
  patch '/:user_name/link' => 'users#user_game_link', as: 'game_link_update'
  patch '/:user_name' => 'users#update', as: 'user_update'

  # Routing for game boards
  get '/category/new' => 'categories#new'
  post '/category' => 'categories#create'
  get '/board/:id/edit' => 'posts#edit', as: 'edit_post'
  get '/board/:game_name' => 'categories#show'
  get '/board/:game_name/new' => 'posts#new', as: 'new_post'
  post '/board/:game_name/' => 'posts#create', as: 'posts'
  get '/board/:game_name/:id' => 'posts#show', as: 'post'
  patch '/board/:game_name/:id' => 'posts#update', as: 'post_update'
  delete '/board/:game_name/:id' => 'posts#destroy'
  # Routing for image upload
  post '/uploads' => 'posts#upload_image'
  
  # Routing for board comments
  post '/posts/:id/comments' => 'posts#create_comment'
  delete '/posts/comments/:comment_id' => 'posts#destroy_comment'
  patch '/posts/comments/:comment_id' => 'posts#update_comment'
  
  # Routing for like
  get '/likes/:post_id' => 'posts#like_post'
  
  # Routing for ajax fetch lol data
  get '/fetch/lol' => 'users#fetch_lol_data'
  get '/fetch/ow' => 'users#fetch_ow_data'
  get '/fetch/pubg' => 'users#fetch_pubg_data'
  
  # Queue matching routes
  post '/players' => 'players#create'
  patch '/players/update' => 'players#update'
  post '/queue/lol_duo' => 'players#duo_match'
  post '/queue/lol_squad' => 'players#team_match_lol'
  post '/queue/pubg_duo' => 'players#duo_match'
  post '/queue/pubg_squad' => 'players#team_match_pubg'
  post '/queue/ow_duo' => 'players#duo_match'
  post '/queue/link' => 'players#link_players'
  
  # Pusher authentication for presence channel
  post '/pusher/auth' => 'pusher#auth'
  
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
