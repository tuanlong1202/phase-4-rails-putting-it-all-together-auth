class RecipesController < ApplicationController
    
    before_action :authorize

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
    # added rescue_from
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response

    # GET /recipes
    def index
        recipes = Recipe.where(user_id = session[user_id])
        render json: recipes, include: :user
    end

    def create    
        recipe = Recipe.new(recipe_params)
        recipe.user_id = session[:user_id]
        if recipe.valid?
          recipe.save
          render json: recipe,include: :user, status: :created
        else
          render json: { errors: recipe.errors.full_messages }, status: :unprocessable_entity
        end
    end
  
    private
    
    def recipe_params
        params.permit(:title, :instructions, :minutes_to_complete)
    end    

    def authorize
      return render json: { errors: ["Not authorized"] }, status: :unauthorized unless session.include? :user_id
    end
  
    def render_not_found_response
        render json: { error: "Recipe not found" }, status: :not_found
    end
  
    def render_unprocessable_entity_response(invalid)
        render json: { errors: invalid.record.errors.full_messages }, status: :unprocessable_entity
    end
    
end
