describe Table do
  describe "repeat" do
    it "repeats data from the previous row" do
      t = Table {
        th :a
        td 1
        td ``
      }

      expect(t.to_a).to eq([{a: 1}, {a: 1}])
    end

    it "repeats data from a previous repeat" do
      t = Table {
        th :a
        td 1
        td ``
        td ``
      }

      expect(t.to_a).to eq([{a: 1}, {a: 1}, {a: 1}])
    end

    it "ignores skips" do
      t = Table {
        th :a
        td 1
        td _
        td ``
      }

      expect(t.to_a).to eq([{a: 1}, {}, {a: 1}])
    end

    it "raises when used in the first row of the definition" do
      t = Table {
        th :a
        td ``
      }

      expect{ t.() {} }.to raise_error(ArgumentError, /repeat/i)
    end

    it "raises when used in the first row after a header change" do
      t = Table {
        th :a
        td 1
        th :a
        td ``
      }

      expect{ t.() {} }.to raise_error(ArgumentError, /repeat/i)
    end

    it "raises when all previous rows contain skips" do
      t = Table {
        th :a
        td _
        td ``
      }

      expect{ t.() {} }.to raise_error(ArgumentError, /repeat/i)
    end
  end
end
