class User < ApplicationRecord
  encrypts :name
  has_encrypted :color
end
