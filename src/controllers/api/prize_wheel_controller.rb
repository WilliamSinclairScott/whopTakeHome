module Api
  class PrizeWheelController < ApplicationController
    def spin
      begin
        user_id = params[:user_id]
        wheel_id = params[:wheel_id]

        job = PrizeWheel::SpinJob,perform_later(user_id, wheel_id)
        render json:  { spin_job_id: job.provider_job_id}
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
      end
    end

    def spin_result
      begin
        spin_job_id = params[:spin_id]
        spin_result = Rails.cache.read("spin_result_#{spin_job_id}")
        if spin_result.nil?
          spin_result = { status: 'pending' }
          # add a more robust handling mechanism for cache misses, such as logging or retrying.
        end
        render json: spin_result
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    def remaining_spins
      begin
        user = User.find(params[:user_id])
        render json: { remaining_spins: user.remaining_spins }
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
      end
    end
  end
end