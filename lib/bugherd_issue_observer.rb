module BugherdIssueObserver
  def after_save(issue)
    field = ProjectCustomField.find_by_name('BugHerd Project Key')
    return unless field

    value = CustomValue.find_by_customized_id_and_custom_field_id(issue.project.id, field.id)
    return unless value

    project_key = value.value
    return unless project_key.present?

    http = Net::HTTP.new('www.bh1.nerdburger.net', 80)
    resp = http.post("/api_v1/projects/#{project_key}/redmine_web_hook", issue.to_xml(
      :only => [:id, :subject, :description],
      :include => {
        :status => {:only => [:id, :name]},
        :priority => {:only => [:id, :name]},
        :tracker => {:only => [:id, :name]},
        :journals => {:only => [:id, :notes, :user], :include => {:user => {:only => [:id, :firstname, :lastname, :login, :mail]}}},
        :project => {:only => [:id, :name]},
        :author => {:only => [:id, :firstname, :lastname, :login, :mail]},
        :assigned_to => {:only => [:id, :firstname, :lastname, :login, :mail]},
      }
    ))
  end
end