class WelcomeController < ApplicationController
  def index
    @header = request.headers["token"]
  end

  def test
    @body = params
  end
end
