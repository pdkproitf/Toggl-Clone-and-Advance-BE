class WelcomeController < ApplicationController
  def index
    @header = request.headers["token"]
  end
end
