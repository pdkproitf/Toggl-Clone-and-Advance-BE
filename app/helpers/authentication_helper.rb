module AuthenticationHelper
    def authenticated!
        error!(I18n.t('Unauthor'), 401) unless current_member
        error!(I18n.t('member.errors.archived'), 401) unless current_member.actived?
    end

    def current_user
        email = request.headers['Uid']
        client_id = request.headers['Client']
        token = request.headers['Access-Token']

        current_user = User.where("tokens ? '#{client_id}'").first

        return current_user unless current_user.nil? || !current_user.valid_token?(token, client_id)
        current_user = nil
    end

    def current_member
        company_domain = request.headers['Company-Domain']
        user = current_user
        return nil unless user

        company = user.companies.find_by_domain(company_domain)
        return nil unless company

        @current_member = user.members.find_by_company_id(company.id)
    end

    def return_message(status, data = nil)
        {
            status: status,
            data: data
        }
    end
end
