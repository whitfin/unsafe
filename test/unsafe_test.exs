defmodule UnsafeTest do
  use ExUnit.Case, async: false

  test "generation with explicit handlers" do
    [{pub_mod, _contents}] = load_file("explicit_public")
    [{prv_mod, _contents}] = load_file("explicit_private")

    validate_mod = fn mod ->
      assert mod.test(true) == {:ok, true}
      assert mod.test(false) == {:error, false}
      assert mod.test!(true) == true

      assert_raise RuntimeError, fn ->
        mod.test!(false)
      end
    end

    validate_mod.(pub_mod)
    validate_mod.(prv_mod)
  end

  test "generation with default handlers" do
    [{pub_mod, _contents}] = load_file("default_public")
    [{prv_mod, _contents}] = load_file("default_private")

    validate_mod = fn mod ->
      assert mod.test(true) == {:ok, true}
      assert mod.test(false) == {:error, false}
      assert mod.test!(true) == true

      assert_raise RuntimeError, fn ->
        mod.test!(false)
      end
    end

    validate_mod.(pub_mod)
    validate_mod.(prv_mod)
  end

  test "generation with multiple definitions" do
    [{arity_mod, _contents}] = load_file("definition_arities")
    [{multi_mod, _contents}] = load_file("definition_multi")

    validate_mod = fn mod ->
      assert mod.test(true) == {:ok, true}
      assert mod.test(true, true) == {:ok, true}

      assert mod.test(false) == {:error, false}
      assert mod.test(false, false) == {:error, false}

      assert mod.test!(true) == true
      assert mod.test!(true, true) == true

      assert_raise RuntimeError, fn ->
        mod.test!(false)
      end

      assert_raise RuntimeError, fn ->
        mod.test!(false, false)
      end
    end

    validate_mod.(arity_mod)
    validate_mod.(multi_mod)
  end

  test "generation with named definitions" do
    [{mod, _contents}] = load_file("definition_named")

    assert mod.test(true) == {:ok, true}
    assert mod.test(true, true) == {:ok, true}

    assert mod.test(false) == {:error, false}
    assert mod.test(false, false) == {:error, false}

    assert mod.test!(true) == true
    assert mod.test!(true, true) == true

    assert_raise RuntimeError, fn ->
      mod.test!(false)
    end

    assert_raise RuntimeError, fn ->
      mod.test!(false, false)
    end
  end

  test "generation with invalid handlers" do
    assert_raise CompileError,
                 ~r/Invalid handler definition for test\/1$/,
                 fn ->
                   load_file("default_invalid")
                 end

    assert_raise CompileError,
                 ~r/Invalid handler definition for test\/1$/,
                 fn ->
                   load_file("explicit_invalid")
                 end
  end

  test "generation with missing handlers" do
    assert_raise CompileError,
                 ~r/Invalid handler definition for test\/1$/,
                 fn ->
                   load_file("handler_missing")
                 end
  end

  test "generation with invalid definitions" do
    assert_raise CompileError, ~r/Invalid function reference provided$/, fn ->
      load_file("definition_invalid")
    end
  end

  defp load_file(file),
    do: Code.require_file("test/modules/#{file}.exs")
end
