module PrizeWheel
  class SpinJob < ApplicationJob
    queue_as :default

    def perform(user_id, wheel_id)
      @user = User.find(user_id)
      @wheel = PrizeWheel.find(wheel_id)
      
      validate_eligibility
      spin = create_spin
      determine_prize(spin)
      update_inventory(spin)

      update_job_status(spin)
    end

    private

    def validate_eligibility
      return if @user.vip?
      if @user.spins_remaining <= 0
        raise StandardError,"No spins remaining" # StandardError.new('No spins remaining')
      end
    end

    def create_spin
      Spin.create!(
        user: @user,
        wheel: @wheel,
        status: 'pending'
      )
    end

    def determine_prize(spin)
      prize = @wheel.prizes.where('stock > 0').sample
      #'rand' returns a float between 0 and 1
      rand_number = rand
      if prize && rand_number <= prize.win_probability
        spin.update!(status: 'won', prize: prize)
      else
        spin.update!(status: 'lost')
      end
    end

    def update_inventory(spin)
      spin.prize.decrement!(:stock) if spin.won?
    end

    def update_job_status(spin)
      # ApplicationJob in Ruby on Rails provides access to provider_job_id.
      job_id = self.provider_job_id
      Rals.cache.write("spin_result_#{job_id}", { status: spin.status, prize: spin.prize&.name })
    end
  end
end