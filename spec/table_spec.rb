describe Table do
  describe "macro" do
    it "is privately callable" do
      expect{ table{} }.not_to raise_error
    end

    it "is not publicly callable" do
      expect{ 123.table{} }.to raise_error(NoMethodError, /private/i)
    end
  end

  describe "definition block" do
    it "with a parameter, is passed a definer object" do
      test = self

      t = table do |t|
        expect(self).to be(test)
        expect(t).to respond_to(:tx, :th , :td, :_, :`)
        expect(t).to respond_to(:x, :h, :d)
      end

      expect(t.to_a).to eq([])
    end

    it "with no parameters, is evaluated in context of a definer object" do
      test = self

      t = table do
        test.expect(self).to test.respond_to(:tx, :th , :td, :_, :`)
        test.expect(self).not_to test.respond_to(:x, :h, :d)
      end

      expect(t.to_a).to eq([])
    end
  end

  describe "call" do
    it "requires a block" do
      e = table{}
      expect{ e.() }.to raise_error(ArgumentError, /block/i)
    end

    it "passes each generated element to the given block" do
      element = nil

      e = table do
        th :abc
        td 123
      end

      e.() { element = _1 }

      expect(element).to eq({abc: 123})
    end

    it "returns the given block result from the row definition" do
      row_ret = nil

      e = table do
                  th :abc
        row_ret = td 123
      end

      e.() { 456 }

      expect(row_ret).to eq(456)
    end

    it "returns the result of the definition block" do
      e = table{ 123 }
      expect(e.() {}).to eq(123)
    end
  end

  describe "each" do
    describe "with a block" do
      it "returns self" do
        element = row_ret = nil

        t = table do
                    th :abc
          row_ret =  td 123
        end

        result = t.each do
          element = _1
          456
        end

        expect(result).to be(t)
        expect(element).to eq({abc: 123})
        expect(row_ret).to eq(456)
      end
    end

    describe "without a block" do
      it "returns an enumerator over the generated elements" do
        result = nil

        t = table do
                    th :abc
          result =  td 123
        end

        e = t.each
        expect(e).to be_a(Enumerator)
        expect(e.next).to eq({abc: 123})

        e.feed(456)
        expect{ e.next }.to raise_error(StopIteration)
        expect(result).to eq(456)
      end
    end
  end

  describe "instance" do
    it "is enumerable" do
      t = table{}

      expect(t).to be_a(Enumerable)
      expect(t).to respond_to(:each)
    end

    it "is reuable" do
      t = table do
        th :abc
        td 123
      end

      expect(t.to_a).to eq([{abc: 123}])
      expect(t.to_a).to eq([{abc: 123}])
      expect(t.to_a).to eq([{abc: 123}])
    end
  end

  describe "shape" do
    it "can be empty" do
      t = table {|_|}
      expect(t.to_a).to eq([])
    end

    it "can have columns but no rows" do
      t = table do
        th :a, :b, :c
      end

      expect(t.to_a).to eq([])
    end

    it "can have rows but no columns" do
      t = table do
        th
        td
        td
        td
      end

      expect(t.to_a).to eq([{}, {}, {}])
    end

    it "can have columns and rows" do
      t = table do
        th :a, :b, :c
        td 1,  2,  3
        td 4,  5,  6
        td 7,  8,  9
      end

      expect(t.to_a).to eq([
        {a: 1, b: 2, c: 3},
        {a: 4, b: 5, c: 6},
        {a: 7, b: 8, c: 9},
      ])
    end

    it "accepts arbitrary objects as column keys" do
      c = Object.new

      t = table do
        th :a, 'b', c
        td 1,  2,   3
      end

      expect(t.to_a).to eq([{a: 1, 'b' => 2, c => 3}])
    end

    it "can change" do
      t = table do
        th :a, :b, :c
        td 1,  2,  3

        th :d, :e
        td 4,  5
      end

      expect(t.to_a).to eq([{a: 1, b: 2, c: 3}, {d: 4, e: 5}])
    end

    it "must have a header before any data" do
      t = table { td }
      expect{ t.each{} }.to raise_error(ArgumentError, /columns/i)
    end

    it "does not allow long data rows" do
      t = table do
        th :a
        td 1, 2
      end

      expect{ t.to_a }.to raise_error(ArgumentError, /wrong number of columns/i)
    end

    it "does not allow short data rows" do
      t = table do
        th :a, :b
        td 1
      end

      expect{ t.to_a }.to raise_error(ArgumentError, /wrong number of columns/i)
    end
  end

  describe "extra" do
    it "is added to each generated element" do
      t = table do
        tx c: 9

        th :a, :b
        td 1,  2
        td 3,  4
      end

      expect(t.to_a).to eq([
        {a: 1, b: 2, c: 9},
        {a: 3, b: 4, c: 9},
      ])
    end

    it "perists across header changes" do
      t = table do
        tx c: 9

        th :a, :b
        td 1,  2

        th :x, :y
        td 3,  4
      end


      expect(t.to_a).to eq([
        {a: 1, b: 2, c: 9},
        {x: 3, y: 4, c: 9},
      ])
    end

    it "accepts arbitrary objects as keys" do
      c = Object.new

      t = table do
        tx a: 1, 'b' => 2, c => 3, nil => 4

        th
        td
      end

      expect(t.to_a).to eq([{a: 1, 'b' => 2, c => 3, nil => 4}])
    end

    it "is shadowed by column data" do
      t = table do
        tx a: 1
        th :a
        td 2
      end

      expect(t.to_a).to eq([{a: 2}])
    end

    it "can be changed" do
      t = table do
        tx a: 1
        th
        td
        tx a: 2
        td
      end

      expect(t.to_a).to eq([{a: 1}, {a: 2}])
    end

    it "can be cleared" do
      t = table do
        tx a: 1
        th
        td
        tx
        td
      end

      expect(t.to_a).to eq([{a: 1}, {}])
    end
  end

  describe "skip" do
    it "omits a column from a row" do
      t = table do
        th :a, :b, :c
        td _,  2,  3
        td 4,  _,  6
        td 7,  8,  _
      end

      expect(t.to_a).to eq([
        {b: 2, c: 3},
        {a: 4, c: 6},
        {a: 7, b: 8},
      ])
    end

    it "uses extra data when the key matches" do
      t = table do
        tx a: 1
        th :a
        td _
      end

      expect(t.to_a).to eq([{a: 1}])
    end
  end

  describe "repeat" do
    it "repeats data from the previous row" do
      t = table do
        th :a
        td 1
        td ``
      end

      expect(t.to_a).to eq([{a: 1}, {a: 1}])
    end

    it "repeats data from a previous repeat" do
      t = table do
        th :a
        td 1
        td ``
        td ``
      end

      expect(t.to_a).to eq([{a: 1}, {a: 1}, {a: 1}])
    end

    it "ignores skips" do
      t = table do
        th :a
        td 1
        td _
        td ``
      end

      expect(t.to_a).to eq([{a: 1}, {}, {a: 1}])
    end

    it "raises when used in the first row of the definition" do
      t = table do
        th :a
        td ``
      end

      expect{ t.() {} }.to raise_error(ArgumentError, /repeat/i)
    end

    it "raises when used in the first row after a header change" do
      t = table do
        th :a
        td 1
        th :a
        td ``
      end

      expect{ t.() {} }.to raise_error(ArgumentError, /repeat/i)
    end

    it "raises when all previous rows contain skips" do
      t = table do
        th :a
        td _
        td ``
      end

      expect{ t.() {} }.to raise_error(ArgumentError, /repeat/i)
    end
  end
end
