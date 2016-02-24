require 'rails_helper'

describe '.create class method' do
  context "with well-formed value argument" do
    before do
      SiteConfig['corporate_services.internal_documents.filetypes'] = []
    end

    it "should be saved as a setting" do
      expect(@return_value = Filetype.create(:ext => "FOOD",:model => InternalDocument)).to be_a Filetype
      expect(@return_value.ext).to eq "food"
      expect(SiteConfig['corporate_services.internal_documents.filetypes']).to eq ["food"]
    end
  end

  context "with non-letter characters" do
    before do
      SiteConfig['corporate_services.internal_documents.filetypes'] = []
    end

    it "should be cleaned up and saved as a setting" do
      expect(@return_value = Filetype.create(:ext => ".pst ", :model => InternalDocument)).to be_a Filetype
      expect(@return_value.ext).to eq "pst"
      expect(SiteConfig['corporate_services.internal_documents.filetypes']).to eq ["pst"]
    end
  end

  context "with value argument greater than 4 characters" do
    before do
      SiteConfig['corporate_services.internal_documents.filetypes'] = []
    end

    it "should not be saved, it should have errors" do
      expect(@return_value = Filetype.create(:ext => "drink", :model => InternalDocument)).to be_a Filetype
      expect(@return_value.ext).to eq "drink"
      expect(SiteConfig['corporate_services.internal_documents.filetypes']).to eq []
      expect(@return_value.errors.full_messages.first).to eq "Filetype too long, 4 characters maximum."
    end
  end

  context "with duplicate value" do
    it "should not be saved, it should have errors" do
      SiteConfig['corporate_services.internal_documents.filetypes'] = ["asm"]
      expect(@return_value = Filetype.create(:ext => "asm", :model => InternalDocument)).to be_a Filetype
      expect(@return_value.ext).to eq "asm"
      expect(SiteConfig['corporate_services.internal_documents.filetypes']).to eq ["asm"]
      expect(@return_value.errors.full_messages.first).to eq "Filetype already exists, must be unique."
    end
  end

  context "with nil value" do
    before do
      SiteConfig['corporate_services.internal_documents.filetypes'] = []
    end

    it "should not be saved, it should have errors" do
      expect(@return_value = Filetype.create(:ext => nil, :model => InternalDocument)).to be_a Filetype
      expect(@return_value.ext).to eq nil
      expect(SiteConfig['corporate_services.internal_documents.filetypes']).to eq []
      expect(@return_value.errors.full_messages.first).to eq "Filetype can't be blank"
    end
  end

  context "with value too short" do
    before do
      SiteConfig['corporate_services.internal_documents.filetypes'] = []
    end

    it "should not be saved, it should have errors" do
      expect(@return_value = Filetype.create(:ext => "x", :model => InternalDocument)).to be_a Filetype
      expect(@return_value.ext).to eq "x"
      expect(SiteConfig['corporate_services.internal_documents.filetypes']).to eq []
      expect(@return_value.errors.full_messages.first).to eq "Filetype too short, must be at least 2 characters."
    end
  end
end
