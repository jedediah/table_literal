describe "instance" do
  it "is enumerable" do
    t = Table {}

    expect(t).to be_a(Enumerable)
    expect(t).to respond_to(:each)
  end

  it "is reuable" do
    t = Table {
      th :abc
      td 123
    }

    expect(t.to_a).to eq([{abc: 123}])
    expect(t.to_a).to eq([{abc: 123}])
    expect(t.to_a).to eq([{abc: 123}])
  end

  it "can be used as a definition block for another table" do
    t1 = Table {
      th :abc
      td 123
    }

    t2 = Table(&t1)

    expect(t2.to_a).to eq([{abc: 123}])
  end
end
