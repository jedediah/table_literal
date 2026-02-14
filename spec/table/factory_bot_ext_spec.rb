require 'factory_bot'
require 'table/factory_bot'

Cat = Struct.new(:name, :age, :breed)

FactoryBot.define do
  factory :cat, class: Cat do
    name    { 'Stray' }
    age     {}
    breed   { 'Unknown' }
  end
end

cats_table = Table {
  th :name     , :age , :breed
  td 'Alice'   , 2    , 'tabby'
  td 'Bob'     , 5    , 'tuxedo'
  td 'Charlie' , 1    , 'persian'
}

cats = cats_table.map{ Cat.new(**_1) }

describe "factory_bot_ext" do
  it "builds instances" do
    expect(FactoryBot.build_table(:cat, &cats_table)).to eq(cats)
  end

  it "gets attributes" do
    expect(FactoryBot.attributes_for_table(:cat, &cats_table)).to eq(cats_table.to_a)
  end

  it "calls a custom strategy" do
    FactoryBot.register_strategy(:spawn, FactoryBot::Strategy::Build)
    expect(FactoryBot.spawn_table(:cat, &cats_table)).to eq(cats)
  end

  it "returns factory result from row definition" do
    cat_attrs = cats_table.first
    cat = nil

    FactoryBot.build_table(:cat) do
            th *cat_attrs.keys
      cat = td *cat_attrs.values
    end

    expect(cat).to eq(cats[0])
  end

  it "does not override attributes without a column" do
    cat = FactoryBot.build_table(:cat) do
      th :age
      td 2
    end[0]

    expect(cat).to have_attributes(name: 'Stray', age: 2, breed: 'Unknown')
  end

  it "does not override ignored cells" do
    cat = FactoryBot.build_table(:cat) do
      th :name , :age , :breed
      td _     , 2    , _
    end[0]

    expect(cat).to have_attributes(name: 'Stray', age: 2, breed: 'Unknown')
  end
end
