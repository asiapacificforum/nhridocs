require 'rails_helper'

describe "CaseReference in the current year"  do
  before do
    @case_reference = CaseReference.new("C#{Date.today.strftime("%y")}-18")
  end

  it "should produce a value for the next reference in the current year" do
    expect(@case_reference.next_ref).to eq "C#{Date.today.strftime("%y")}-19"
  end
end

describe "CaseReference in the previous year"  do
  before do
    @case_reference = CaseReference.new("C#{Date.today.strftime("%y").to_i-1}-18")
  end

  it "should produce a value for the next reference in the current year" do
    expect(@case_reference.next_ref).to eq "C#{Date.today.strftime("%y")}-1"
  end
end

describe "CaseReference comparing values" do
  before do
    @list = [
      CaseReference.new("C16-15"),
      CaseReference.new("C16-1"),
      CaseReference.new("C17-10"),
      CaseReference.new("C17-1")
    ]
  end

  it "should sort by year and sequence" do
    expect(@list.sort.map(&:ref)).to eq ["C16-1", "C16-15", "C17-1", "C17-10"]
  end

  it "should calculate the next value" do
    if Date.today.year == 2017
      next_ref = "C17-11"
    else
      next_ref = "C#{Date.today.strftime("%y")}-1"
    end
  end
end
