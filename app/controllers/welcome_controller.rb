class WelcomeController < ApplicationController
  def index
    @header = request.headers["token"]
  end

  def test
    @body = params["project"]
  end
end
