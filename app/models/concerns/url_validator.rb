module UrlValidator extend ActiveSupport::Concern
    def url_valid?(url)
        url = URI.parse(url) rescue false
        url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
    end
end
