module User
  class Data < Grape::API
 
    resource :user_data do
      desc "List all Users"
 
      get do
        Users.all
      end
 
    end
 
  end
end