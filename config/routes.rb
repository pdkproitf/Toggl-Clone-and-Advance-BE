Rails.application.routes.draw do
  root 'welcome#index'
  post "test", to: "welcome#test"
end
