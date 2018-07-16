# frozen_string_literal: true

require "spec_helper"

RSpec.describe Person, type: :model, versioning: true do
  it "baseline test setup" do
    expect(Person.new).to be_versioned
  end

  # Was originally a skipped example from Issue #594.  See:
  #   https://github.com/airblade/paper_trail/issues/594
  # Fixed by utilising the correct sub type of the STI model.
  describe "#cars and bicycles" do
    it "can be reified" do
      person = Person.create(name: "Frank")
      car = Car.create(name: "BMW 325")
      bicycle = Bicycle.create(name: "BMX 1.0")

      person.car = car
      person.bicycle = bicycle
      person.update_attributes(name: "Steve")

      car.update_attributes(name: "BMW 330")
      bicycle.update_attributes(name: "BMX 2.0")
      person.update_attributes(name: "Peter")

      expect(person.reload.versions.length).to(eq(3))

      second_version = person.reload.versions.second.reify(has_one: true)
      expect(second_version.car.name).to(eq("BMW 325"))
      expect(second_version.bicycle.name).to(eq("BMX 1.0"))
    end
  end
end