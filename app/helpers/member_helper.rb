module MemberHelper
    def able_see_member?(member)
        current_member.manager? && (member.company_id == @current_member.company_id)
    end

    def able_modify_member?(member)
        able_see_member?(member) && @current_member.admin?
    end
end
