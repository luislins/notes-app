module SessionTestHelper
  def sign_in_as(user)
    session = user.sessions.create!
    Current.session = session
    @auth_token = session.token
  end

  def auth_headers
    { "Authorization" => "Bearer #{@auth_token}" }
  end

  def sign_out
    Current.session&.destroy!
    @auth_token = nil
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include SessionTestHelper
end
