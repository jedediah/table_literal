describe Table do
  describe "each" do
    describe "with a block" do
      it "returns self" do
        element = row_ret = nil

        t = Table {
                    th :abc
          row_ret = td 123
        }

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

        t = Table {
                    th :abc
          result =  td 123
        }

        e = t.each
        expect(e).to be_a(Enumerator)
        expect(e.next).to eq({abc: 123})

        e.feed(456)
        expect{ e.next }.to raise_error(StopIteration)
        expect(result).to eq(456)
      end
    end
  end
end
