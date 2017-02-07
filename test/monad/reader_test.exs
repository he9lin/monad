defmodule Monad.ReaderTest do
  use ExUnit.Case, async: true

  require Monad.Reader, as: Reader
  import Reader

  doctest Reader

  test "Monad.Reader left identity" do
    f = fn (x) -> return(x * x) end
    a = 2
    assert run(10, bind(return(a), f)) == run(10, f.(a))
  end

  test "Monad.Reader right identity" do
    m = return 42
    assert run(10, bind(m, &return/1)) == run(10, m)
  end

  test "Monad.Reader associativity" do
    f = fn (x) -> return(x * x) end
    g = fn (x) -> return(x - 1) end
    m = return 2
    assert run(10, bind(m, f) |> bind(g)) == run(10, bind(m, &bind(f.(&1), g)))
  end

  test "Monad.Reader ask" do
    assert run(4, (Reader.m do
                     x <- return 2
                     y <- ask
                     return (x * y)
                   end)) == 8
  end

  test "Monad.Reader local" do
    assert run(4, (local(ask, &(&1+1)))) == 5
  end

  defp reader_times(x) do
    Reader.m do
      y <- ask
      return(x * y)
    end
  end

  defp reader_minus(x) do
    Reader.m do
      y <- ask
      return(x - y)
    end
  end

  test "Monad.Reader pipeline with do" do
    r = Monad.Reader.p do
      return(3)
      |> reader_times
      |> reader_minus
    end

    assert run(10, r) == 20
  end
end
