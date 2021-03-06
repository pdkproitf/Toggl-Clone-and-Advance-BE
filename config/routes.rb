Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  root 'welcome#index'
  get 'export/export'
  post 'test', to: 'welcome#test'
  mount API::Root => '/'
  mount GrapeSwaggerRails::Engine => '/swagger'
  delete 'sig', to: 'welcome#temp'

  mount LetterOpenerWeb::Engine, at: '/devel/emails' if Rails.env.development?
end
