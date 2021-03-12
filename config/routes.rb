Rails.application.routes.draw do
  resources :lists
  put '/list/:id/addCompany/:company_id', to: 'lists#addCompany', as: 'addCompanyToList'
  put '/list/:id/removeCompany/:company_id', to: 'lists#removeCompany', as: 'removeCompanyFromList'
  patch '/list/:id/moveCompany/:company_id', to: 'lists#moveCompany', as: 'moveCompanyOnList'
  resources :transactions
  resources :accounts
  resources :companies do
    resources :notes
  end
  # get '/company/:id/updateFinancials', to: 'companies#updateFinancials', as: 'updateFinancials'
  get '/company/addUSCompanies', to: 'companies#addUSCompanies', as: 'addUSCompanies'
  get '/company/updateCompanies', to: 'companies#updateCompanies', as: 'updateCompanies'
  
  root 'welcome#index'
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
