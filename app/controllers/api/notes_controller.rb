module Api
  class NotesController < ApplicationController
    before_action :set_note, only: [:show, :update, :destroy]

    def index
      notes = Current.user.notes.order(created_at: :desc)
      render json: notes
    end

    def show
      render json: @note
    end

    def create
      note = Current.user.notes.build(note_params)

      if note.save
        render json: note, status: :created
      else
        render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @note.update(note_params)
        render json: @note
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
      params.expect(note: [:title, :content])
    end
  end
end
