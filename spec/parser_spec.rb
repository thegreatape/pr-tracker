require 'parser'

describe Parser do
  it "parses" do
    expect(Parser.new.parse("foo")).to_not be_nil
  end
end
