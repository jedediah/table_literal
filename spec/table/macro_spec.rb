describe Table do
  describe "macro" do
    it "is privately callable" do
      expect{ Table {} }.not_to raise_error
    end

    it "is not publicly callable" do
      expect{ 123.Table {} }.to raise_error(NoMethodError, /private/i)
    end
  end
end
