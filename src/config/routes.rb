Rails.application.routes.draw do

  namespace :api do
    post 'prize_wheel/spin', to 'prize_wheel#spin'
    get 'prize_wheel/spin_result/:spin_id', to: 'prize_wheel#spin_result'
    get 'prize_wheel/:user_id/remaining_spins', to: 'prize_wheel#remaining_spins'
  end
  
end