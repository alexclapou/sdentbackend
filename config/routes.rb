Rails.application.routes.draw do
  namespace :api do
    resources :statistics do
      collection do
        get 'user_appointments_stats', to: 'statistics#users_appointments_number'
        get 'equipments_used/:id', to: 'statistics#cabinet_used_equipments'
        get 'equipments', to: 'statistics#equipments'
        get 'all_used_equipments', to: 'statistics#all_used_equipments'

      end
    end
    
    get 'locations/:id', to: 'location#location_by_city'
    resources :cabinets, only: %i[show index update] do
      collection do
        post 'update_equipment/:id/material/:mid/quantity/:quantity',
             to: 'cabinets#update_equipment_quantity'
        get '/:id/equipments',
             to: 'cabinets#cabinet_equipments'
      end
    end
    resources :appointments, only: %i[index show] do
      collection do
        post 'request_appointment', to: 'appointments#request_appointment'
        post 'cancel_appointment/:id', to: 'appointments#cancel_appointment'
        post 'confirm_appointment/:id/assistant/:aid', to: 'appointments#confirm_appointment'
        post 'complete_appointment/:id', to: 'appointments#complete_appointment'
        get 'user_appointments', to: 'appointments#show'
        get 'unavailable_dates/:id', to: 'appointments#unavailable_dates'
      end
    end
    resources :users, only: %i[index show] do
      collection do
        get ':id/appointments', to: 'users#appointments'
        get 'user_appointments/:id', to: 'users#user_appointments'
        get 'dentists', to: 'users#show_dentists'
        post 'change_settings', to: 'users#change_user_settings'
        post 'change_password', to: 'users#change_user_password'
        get 'current_user_name/:id', to: 'users#get_user_fullname'
        get 'current_user_email/:id', to: 'users#get_user_email'
      end
    end
  end
  namespace :admin do
    post 'set_dentist', to: 'cabinets#set_dentist'
  end
  namespace :auth do
    post 'login', to: 'authentication#login'
    post 'register', to: 'authentication#register'
    post 'logout', to: 'authentication#logout'
    get 'confirmation/*token', to: 'confirmations#confirm_email', constraints: { token: /.*/ }
    post 'refresh', to: 'authentication#refresh'
    post 'remove_refresh_token', to: 'authentication#remove_refresh_token'
  end
  get 'signed', to: 'application#signed_in'
end