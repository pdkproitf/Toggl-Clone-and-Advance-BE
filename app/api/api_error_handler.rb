class ApiErrorHandler < Grape::Middleware::Base
    def call!(env)
        @env = env
        begin
            @app.call(@env)
        rescue Exception => e
            throw :error, :message => e.message || options[:default_message], :status => 400
        end
    end
end
