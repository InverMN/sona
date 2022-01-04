defmodule SonaTest do
  use ExUnit.Case
  doctest Sona

  test "greets the world" do
    assert Sona.hello() == :world
  end
end
