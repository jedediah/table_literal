describe "ignore" do
  it "omits a column from a row" do
    t = Table {
      th :a, :b, :c
      td _,  2,  3
      td 4,  _,  6
      td 7,  8,  _
    }

    expect(t.to_a).to eq([
      {b: 2, c: 3},
      {a: 4, c: 6},
      {a: 7, b: 8},
    ])
  end

  it "uses extra data when the key matches" do
    t = Table {
      tx a: 1
      th :a
      td _
    }

    expect(t.to_a).to eq([{a: 1}])
  end
end
