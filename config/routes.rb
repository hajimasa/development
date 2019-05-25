Rails.application.routes.draw do
  root to: 'home#top'
  get 'home/top'
  get 'ajax/get_my_location_information_data'
  post 'ajax/get_my_location_information_data'
end
