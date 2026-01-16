Rails.application.routes.draw do
  resources :quest_step_lesson_payloads
  resources :quest_step_lessons

  resources :phrase_orderings
  resources :phrase_input_permits
  resources :material_tags
  resources :material_tag_options do
    collection do
      get :search
    end
  end
  resources :material_categories
  resources :material_category_options
  resources :phrase_input_payloads
  resources :phrase_inputs
  resources :factory_dynamic_outputs
  resources :factory_dynamic_inputs
  resources :factory_material_details
  resources :phrase_factories
  resources :phrase_dynamics
  resources :factory_dynamic_parameters
  resources :pronouns
  resources :factory_dynamics
  resources :factory_materials do
    collection do 
      post :search
    end
    member do
      get :suggest_details
    end
  end
  resources :reactions
  resources :factory_rules
  resources :factories do 
    collection do 
      post :fetch
    end
  end
  resources :language_adjectives
  resources :fragments
  resources :possessions
  resources :adjectives
  resources :adjective_rules
  resources :noun_rules
  resources :language_nouns
  resources :nouns
  resources :language_verbs
  resources :verbs
  resources :conjugation_rules
  resources :bottle_feedbacks
  resources :bottles
  resources :prompts
  resources :user_missions
  resources :videos
  resources :missions
  resources :phrases do
    collection do
      post :verify_built_by_wizard
    end
  end
  resources :key_phrases

  resources :poems
  resources :lesson_plans
  resources :language_traits
  resources :traits
  resources :languages
  resources :traits
  resources :universals
  resources :articles
  resources :machines
  resources :word_blocks, only: [:index]

  resources :games

  # config/routes.rb
  resources :quests do
    collection do
      get :popular
      post :quest_generation_wizard
    end
    resources :quest_steps do
      member do
        post :upload_image
      end
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  resources :lessons do
    collection do
      post :reorder
      get :generate_language_expression
    end
  end

  resources :lesson_keys

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  get "/all_languages" => "languages#index"
  get "/populated_languages" => "languages#populated"


  post "/factory_dynamics/run" => "factory_dynamics#run"
  get "/languages/:id/factory_materials/by_param/:param" => "factory_materials#by_param"
  put "/dynamic_rules/reorder" => "dynamic_rules#reorder"
  resources :dynamic_rules
  get "/languages/:id/lessons" => "languages#lessons"
  get "/languages/:id/quiz" => "languages#quiz"

  get "/expressions/:id/generate_scenarios" => "lessons#generate_scenarios"


  get "/conjugations/sample" => "conjugations#sample"
  
  resources :conjugations

  get '/languages/:id/material_tag_options' => "languages#material_tag_options"
  
  
  post "/factory_dynamics/build" => "factory_dynamics#build"
  get "languages/:id/factory_dynamics" => "factory_dynamics#by_language"

  post "/conjugator/build" => "conjugator#build"
  get "/conjugator/tester" => "conjugator#tester"

  post "/possessions/build" => "possessions#build"
  post "/fragments/build" => "fragments#build"
  # post "/possessions/build" => "possessions#build"

  get "/dynamics/:id/quiz" => "factory_dynamics#quiz"

  get "/privacy" => "legal#privacy"
  get "/policies/privacy" => "legal#privacy"
  get "/privacy_policy" => "legal#privacy"
  get "/ads.txt" => "legal#ads"

  

  get "/terms" => "legal#terms"
  get "/disclaimer" => "legal#disclaimer"


  # 
  post '/subscriptions/new' => "stripe/checkouts#new"
  post '/cancel_subscription' => "stripe#cancel"

  post "/stripe/sessions" => "stripe/checkouts#new"
  post "/stripe/checkout/webhook" => "stripe/checkouts#webhook"
  get "/success" => "stripe#success"
  get "/membership" => "stripe#subscription"

  post "/stripe/gifts" => "stripe/gifts#new"
  # 
  post "/reactions/build" => "reactions#build"

  # QUIZMAKER
  get "/reactions/:id/quiz" => "reactions#quiz"
  get "/phrases/:id/quiz" => "phrases#quiz"

  post "/conjugations/build" => "conjugations#build"
  get "/languages/:id/verbs_quiz" => "language_verbs#quiz"

  get "/languages/:id/verbs" => "language_verbs#edit"
  get "/languages/:id/conjugations" => "conjugations#edit"
  get "/languages/:id/conjugation_rules" => "conjugation_rules#edit"
  get "/languages/:id/factories" => "factories#edit"

  get "/languages/:id/machines" => "machines#by_language"

  get "/phrases/:id/build" => "phrases#build"

  get "/lessons/catalog/search/:search" => "lessons#search_catalog"
  post "/languages/link_lesson" => "lessons#link_lesson"

  get "/languages/:id/nouns" => "language_nouns#edit"
  get "/languages/:id/possessions" => "possessions#edit"
  get "/languages/:id/noun_rules" => "noun_rules#edit"

  get "/languages/:id/adjectives" => "language_adjectives#edit"
  get "/languages/:id/fragments" => "fragments#edit"
  get "/languages/:id/adjective_rules" => "adjective_rules#edit"

  post "upload_image" => "uploader#upload_image"

  get "/rap" => "pages#rap"

  get "/missions/new/:phrase_id" => "missions#new"

  get "/missions/:id/present" => "missions#present"
  
  get "/missions/:id/edit" => "missions#edit"

  get "/random_mission" => "missions#get_random"
  post "/test_from_list" => "phrases#test_from_list"

# 
  get "/control_panel" => "control_panel#show"
# 

  get "/blanks" => "blanks#index"

  post "/language_traits/make" => "language_traits#make"

  post '/save_lesson_key' => 'lesson_keys#save'
  post '/find_lesson_key' => 'lesson_keys#find'
  post '/traits/factory' => 'language_traits#fetch_factory'
  post '/traits/factory/save' => 'language_traits#factory_save'

  get '/cached_traits' => "traits#cached"

  post "/factory_rules/reorder" => "factory_rules#reorder"

  post "/phrase_inputs/:id/save_payload" => "phrase_inputs#save_payload"
  # 
  get "/languages/:language_id/lessons/:lesson_id/phrases" => "lessons#phrases"
  post '/phrases/search' => 'phrases#search'
  post '/videos/search' => 'videos#search'

  get '/quiz/:id' => 'quiz#quiz'
  get '/get_random_quiz/:id' => 'quiz#get_random_quiz'
  get '/get_lesson_plan_quiz/:id' => 'quiz#get_lesson_plan_quiz'

  get '/lesson_plans/:lesson_plan_id/new_lesson' => 'lessons#new'
  get '/lesson_plans/:id/quiz' => 'lesson_plans#quiz'

  get "/lang_concepts/:trait_id/:language_id" => "language_traits#lang_concept"

  get "/phrasebook" => 'pages#phrasebook'

  get "/language_traits/:trait_id/new" => 'language_traits#new'
  get "/language_traits/:trait_id/new/:language_id" => 'language_traits#new'

  get "/traits_factory" => 'language_traits#factory'

  get "/test/traits" => 'traits#test'


  post "/config_traits" => "traits#config_traits"

  get "/landing" => 'pages#landing'

  get '/lessons' => "lessons#index"
  get '/expressions' => "lessons#index"
  
  get '/expressions/:id' => "lessons#show"
  get '/expressions/:id/edit' => "lessons#edit"

  get "/languages/:id/phrases" => "languages#phrases"

  post 'factory_dynamics/run_config', to: 'factory_dynamics#run_config'
  post 'factory_dynamics/run_flow_config', to: 'factory_dynamics#run_config'

  post '/lessons/search' => 'lessons#search'
  post '/traits/search' => 'traits#search'

  get '/cardify' => 'cardify#simple'
  get '/cardify/:id' => 'cardify#simple'

  get '/factories/:id/materials' => 'factory_materials#by_factory'
  get '/factories/:id/sample_materials' => 'factories#sample_materials'
  get '/factory_dynamics/:id/build' => "factory_dynamics#build"

  post '/update_mission' => 'portfolio#update_mission'

  get '/:username' => "portfolio#home", :constraints => { :username => /[^\/]+/ }

  root 'pages#home'

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