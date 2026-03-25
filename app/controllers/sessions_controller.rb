class SessionsController < ApplicationController
  allow_unauthenticated_access only: [:create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    render json: { error: "Muitas tentativas. Tente novamente mais tarde." }, status: :too_many_requests
  }

  def create
    if user = User.authenticate_by(session_params)
      start_new_session_for(user)
      render json: { token: Current.session.token, user: user_json(user) }
    else
      render json: { errors: ["E-mail ou senha inválidos"] }, status: :unauthorized
    end
  end

  def destroy
    terminate_session
    render json: { message: "Sessão encerrada" }
  end

  private

  def session_params
    params.permit(:email_address, :password)
  end

  def user_json(user)
    { id: user.id, email_address: user.email_address }
  end
end
