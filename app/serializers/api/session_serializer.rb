class Api::SessionSerializer < Api::BaseSerializer
  #just some basic attributes
  attributes :id, :email, :name, :token

  #def token
  #  object.auth_token
  #end
end