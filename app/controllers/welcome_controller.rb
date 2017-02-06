class WelcomeController < ApplicationController
    def temp
      respond_to do |format|
        format.json {  render json: {'te' => 'teafd'} }
      end
        # @header = request.headers['token']
    end

    def test
        @body = params['project']
    end
end
