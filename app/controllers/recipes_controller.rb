class RecipesController < ApplicationController
  def index
    @recipes = Recipe.all!
  end

  def show
    @recipe = Recipe.one!(params[:id])
  end
end
