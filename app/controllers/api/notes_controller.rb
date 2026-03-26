module Api
  class NotesController < ApplicationController
    before_action :set_note, only: [:show, :update, :destroy]

    def index
      page = [params.fetch(:page, 1).to_i, 1].max
      per_page = params.fetch(:per_page, 12).to_i.clamp(1, 50)

      notes = Current.user.notes.includes(:category).order(created_at: :desc)
      total = notes.count
      paginated = notes.offset((page - 1) * per_page).limit(per_page)

      render json: {
        notes: paginated.map { |note| serialize(note) },
        meta: { page: page, per_page: per_page, total: total, total_pages: (total.to_f / per_page).ceil }
      }
    end

    def show
      render json: serialize(@note)
    end

    def create
      note = Current.user.notes.build(note_params)

      if note.save
        render json: serialize(note), status: :created
      else
        render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @note.update(note_params)
        render json: serialize(@note)
      else
        render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @note.destroy
      head :no_content
    end

    private

    def set_note
      @note = Current.user.notes.find(params[:id])
    end

    def note_params
      params.expect(note: [:title, :content, :category_id])
    end

    def serialize(note)
      note.as_json(only: [:id, :title, :content, :category_id, :created_at, :updated_at])
          .merge(category: note.category&.as_json(only: [:id, :name, :color]))
    end
  end
end
