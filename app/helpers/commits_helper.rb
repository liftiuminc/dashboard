module CommitsHelper
  def commits_title(params)
    if params[:record_id] && params[:record_type]
      "Changelogs - Filtered by #{params[:record_type]} with id #{params[:record_id]} (#{link_to("Show All", commits_path)})"
    elsif params[:user_id] && user = User.find_by_id(params[:user_id])
      "Changelogs - Filtered by #{user.email}'s changes (#{link_to("Show All", commits_path)})"
    else
      title = "Changelogs - Showing #{@entries || "all"} entries"
      title += " excluding #{User.find_by_id(params[:excluded_user_id]).email} (#{link_to("Show All", commits_path)})" if params[:excluded_user_id] && params[:excluded_user_id] != "none"
      title
    end
  end
end
