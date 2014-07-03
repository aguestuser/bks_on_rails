require 'spec_helper'

describe Staffer do
  
  describe "attributes" do
    it { should respond_to(:title) }
  end

  describe "associations" do
    describe "contact info" do
      it { should respond_to(:contact_info)}
    end
  end
end
