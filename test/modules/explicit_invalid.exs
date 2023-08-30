defmodule UnsafeTest.ExplicitInvalid do
  use Unsafe.Generator

  @unsafe [{:test, 1, "invalid"}]

  def test(true),
    do: {:ok, true}

  def test(false),
    do: {:error, false}
end
