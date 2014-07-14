module ManagerPageMacros
  def get_manager_form_hash
    {
      fields: {
        'Name' => contact.name,
        'Title' => contact.title,
        'Phone' => contact.phone,
        'Email' => contact.email
      },
      selects: {},
      checkboxes: []
    }
  end
end