module Api
  class NotesController < ApplicationController
    before_action :set_note, only: [:show, :update, :destroy]

    def index
      notes = Current.user.notes.includes(:category).order(created_at: :desc)
      render json: notes.map { |note| serialize(note) }
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
