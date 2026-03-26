module Api
  class CategoriesController < ApplicationController
    before_action :set_category, only: [:update, :destroy]

    def index
      categories = Current.user.categories.order(:name)
      render json: categories
    end

    def create
      category = Current.user.categories.build(category_params)

      if category.save
        render json: category, status: :created
      else
        render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @category.update(category_params)
        render json: @category
      else
        render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @category.destroy
      head :no_content
    end

    private

    def set_category
      @category = Current.user.categories.find(params[:id])
    end

    def category_params
      params.expect(category: [:name, :color])
    end
  end
end
