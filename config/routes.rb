Rails.application.routes.draw do
  resources :companies
  # get '/company/:id/updateFinancials', to: 'companies#updateFinancials', as: 'updateFinancials'
  get '/company/addUSCompanies', to: 'companies#addUSCompanies', as: 'addUSCompanies'
  get '/company/updateAllCompanies', to: 'companies#updateAllCompanies', as: 'updateAllCompanies'
  
  root 'welcome#index'
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
