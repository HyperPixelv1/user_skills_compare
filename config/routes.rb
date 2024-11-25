# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
    resources :users, only: [] do
      member do
        get :skills, to: "user_skills_compare#index"
      end
    end
  end