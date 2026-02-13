describe Table do
  describe "definition" do
    definer_methods = [:tx, :th, :td, :_, :`]

    it "with a parameter, is passed a definer object" do
      ctx = arg = nil

      Table { |t|
        ctx = self
        arg = t
      }.() {}

      expect(ctx).to be(self)
      expect(arg).to respond_to(*definer_methods)
    end

    it "with no parameters, is evaluated in context of a definer object" do
      ctx = nil

      Table {
        ctx = self
      }.() {}

      expect(ctx).to respond_to(*definer_methods)
    end

    it "can be a nullary lambda" do
      # Ensure that the definition block can be strictly parameterless,
      # i.e. that it is not passed any unwanted arguments (as instance_eval does).
      Table(&->{}).() {}
    end
  end
end
