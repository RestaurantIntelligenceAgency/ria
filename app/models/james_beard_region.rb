# == Schema Information
#
# Table name: james_beard_regions
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class JamesBeardRegion < ActiveRecord::Base
  has_many :users
  has_many :restaurants

  validates_presence_of :name
  validates_presence_of :description

  def name_and_description(show_parentheses = true)
    @name_and_description ||= begin
      desc = (show_parentheses ? "(#{description})" : description)
      "#{name} #{desc}"
    end
  end
  # Formtastic Labels
  alias :to_label :name_and_description
end
