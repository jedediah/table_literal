describe "definition" do
  it "with a parameter, is passed a definer object" do
    ctx = arg = nil

    Table { |t|
      ctx = self
      arg = t
    }.() {}

    expect(ctx).to be(self)
    expect(arg).to be_a(Table::Evaluation)
  end

  it "with no parameters, is evaluated in context of a definer object" do
    ctx = nil

    Table {
      ctx = self
    }.() {}

    expect(ctx).to be_a(Table::Evaluation)
  end

  it "can be a nullary lambda" do
    # Ensure that the definition block can be strictly parameterless,
    # i.e. that it is not passed any unwanted arguments (as instance_eval does).
    Table(&->{}).() {}
  end
end
