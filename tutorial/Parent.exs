defmodule Parent do
  def spawn_link(limits) do
    spawn_link(__MODULE__, :init, [limits])
  end

  def init(limits) do
    Process.flag :trap_exit, true

    children_pids = Enum.map(limits, fn(limit_num) ->
      pid = run_child(limit_num)
      {pid, limit_num}
    end) |> Enum.into(%{})
    IO.puts "ispect #{inspect children_pids}"
    loop(children_pids)
    
    # Enum.each(limits, fn(limit_num) ->
    #   spawn_link(Child, :init, [limit_num])
    # end)
    # loop()
  end

  def loop(children_pids) do
    receive do
      {:EXIT, pid, _} = msg ->
        IO.puts "Parent get message: #{inspect msg}"
        IO.puts "before inspect loop #{inspect children_pids}"
        {limit, children_pids} = pop_in(children_pids[pid])
        IO.puts "ispect loop #{inspect children_pids}"
        new_pid = run_child(limit)

        children_pids = put_in children_pids[new_pid], limit

        IO.puts "Restart children #{inspect pid}(limt #{limit}) with new pid #{inspect new_pid}"

        loop(children_pids)
    end
  end

  def run_child(limit) do
    spawn_link(Child, :init, [limit])
  end
end

defmodule Child do
  def init(limit) do
  IO.puts "Start child with limit #{limit} pid #{inspect self()}"
    loop(limit)
  end

  def loop(0), do: :ok
  def loop(n) when n > 0 do
    IO.puts "Process #{inspect self()} counter #{n}"
    Process.sleep 500
    loop(n-1)
  end
end

Parent.init([2,3,5])

Process.sleep 1_000
