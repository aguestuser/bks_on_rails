# == Schema Information
#
# Table name: user_infos
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  email      :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  user_type  :string(255)
#

require 'spec_helper'

describe UserInfo do
  pending "add some examples to (or delete) #{__FILE__}"
end
