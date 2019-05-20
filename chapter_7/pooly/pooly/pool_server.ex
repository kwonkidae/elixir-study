defmodule Pooly.PoolServer do
  use GenServer
  import Supervisor.Spec

  defmodule State do
    defstruct pool_sup: nil,
    worker_sup: nil,
    monitors: nil,
    size: nil,
    workers: nil,
    name: nil,
    mfa: nil,
    waiting: nil,
    overflow: nil,
    max_overflow: nil
  end
end
