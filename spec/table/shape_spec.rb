describe "shape" do
  it "can be empty" do
    t = Table {|_|}
    expect(t.to_a).to eq([])
  end

  it "can have columns but no rows" do
    t = Table {
      th :a, :b, :c
    }

    expect(t.to_a).to eq([])
  end

  it "can have rows but no columns" do
    t = Table {
      th
      td
      td
      td
    }

    expect(t.to_a).to eq([{}, {}, {}])
  end

  it "can have columns and rows" do
    t = Table {
      th :a, :b, :c
      td 1,  2,  3
      td 4,  5,  6
      td 7,  8,  9
    }

    expect(t.to_a).to eq([
      {a: 1, b: 2, c: 3},
      {a: 4, b: 5, c: 6},
      {a: 7, b: 8, c: 9},
    ])
  end

  it "accepts arbitrary objects as column keys" do
    c = Object.new

    t = Table {
      th :a, 'b', c
      td 1,  2,   3
    }

    expect(t.to_a).to eq([{a: 1, 'b' => 2, c => 3}])
  end

  it "can change" do
    t = Table {
      th :a, :b, :c
      td 1,  2,  3

      th :d, :e
      td 4,  5
    }

    expect(t.to_a).to eq([{a: 1, b: 2, c: 3}, {d: 4, e: 5}])
  end

  it "must have a header before any data" do
    t = Table { td }
    expect{ t.each{} }.to raise_error(ArgumentError, /columns/i)
  end

  it "does not allow long data rows" do
    t = Table {
      th :a
      td 1, 2
    }

    expect{ t.to_a }.to raise_error(ArgumentError, /wrong number of columns/i)
  end

  it "does not allow short data rows" do
    t = Table {
      th :a, :b
      td 1
    }

    expect{ t.to_a }.to raise_error(ArgumentError, /wrong number of columns/i)
  end

  it "does not allow duplicate column keys" do
    t = Table {
      th :a, :a
    }

    expect{ t.to_a }.to raise_error(ArgumentError, /duplicate/i)
  end
end
