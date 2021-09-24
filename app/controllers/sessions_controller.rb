class SessionsController < ApplicationController
    
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
    # added rescue_from
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response

    def create
        user = User.find_by!(username: params[:username])
        if user&.authenticate(params[:password])
          session[:user_id] = user.id
          render json: user, status: :created
        else
          render json: { errors: "Invalid username or password" }, status: :unauthorized
        end
    end
    def destroy
        if session[:user_id]
            session.delete :user_id
            head :no_content
        else
            render json: {errors: ["Invalid username"] }, status: :unauthorized
        end
    end
  
    private

    def render_not_found_response
        render json: { errors: ["User not found"] }, status: :unauthorized
    end
  
    def render_unprocessable_entity_response(invalid)
        render json: { errors: invalid.record.errors.full_messages }, status: :unprocessable_entity
    end
  
end
