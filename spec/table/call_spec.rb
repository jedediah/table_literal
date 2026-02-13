describe Table do
  describe "call" do
    it "requires a block" do
      e = Table {}
      expect{ e.() }.to raise_error(ArgumentError, /block/i)
    end

    it "passes each generated element to the given block" do
      element = nil

      e = Table {
        th :abc
        td 123
      }

      e.() { element = _1 }

      expect(element).to eq({abc: 123})
    end

    it "returns the given block result from the row definition" do
      row_ret = nil

      e = Table {
                  th :abc
        row_ret = td 123
      }

      e.() { 456 }

      expect(row_ret).to eq(456)
    end

    it "returns the result of the definition block" do
      e = Table { 123 }
      expect(e.() {}).to eq(123)
    end
  end
end
