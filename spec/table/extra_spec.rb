describe "extra" do
  it "is added to each generated element" do
    t = Table {
      tx c: 9

      th :a , :b
      td 1  , 2
      td 3  , 4
    }

    expect(t.to_a).to eq([
      {a: 1, b: 2, c: 9},
      {a: 3, b: 4, c: 9},
    ])
  end

  it "perists across header changes" do
    t = Table {
      tx c: 9

      th :a , :b
      td 1  , 2

      th :x , :y
      td 3  , 4
    }

    expect(t.to_a).to eq([
      {a: 1, b: 2, c: 9},
      {x: 3, y: 4, c: 9},
    ])
  end

  it "accepts arbitrary objects as keys" do
    c = Object.new

    t = Table {
      tx a: 1, 'b' => 2, c => 3, nil => 4

      th
      td
    }

    expect(t.to_a).to eq([{a: 1, 'b' => 2, c => 3, nil => 4}])
  end

  it "is shadowed by column data" do
    t = Table {
      tx a: 1
      th :a
      td 2
    }

    expect(t.to_a).to eq([{a: 2}])
  end

  it "can be changed" do
    t = Table {
      tx a: 1, b: 2
      th
      td
      tx a: 4, c: 3
      td
    }

    expect(t.to_a).to eq([{a: 1, b: 2}, {a: 4, c: 3}])
  end

  it "can be cleared" do
    t = Table {
      tx a: 1
      th
      td
      tx
      td
    }

    expect(t.to_a).to eq([{a: 1}, {}])
  end
end
