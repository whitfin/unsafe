defmodule UnsafeTest.DefaultPrivate do
  use Unsafe.Generator,
    handler: :private_handler

  @unsafe [ test: 1 ]

  def test(true),
    do: { :ok, true }
  def test(false),
    do: { :error, false }

  defp private_handler({ :ok, true }),
    do: true
  defp private_handler({ :error, false }),
    do: raise RuntimeError
end
