defmodule MetexOtp.Worker do
  use GenServer

  ## Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get_temperature(pid, location) do
    GenServer.call(pid, {:location, location})
  end

  def get_stats(pid) do
    GenServer.call(pid, :get_stats)
  end

  def reset_stats(pid) do
    GenServer.cast(pid, :reset_stats)
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
  end

  ## Server Callback
  def init(:ok) do
    {:ok, %{}}
  end

  ## Server API

  def handle_call({:location, location}, _from, stats) do
    case temperature_of(location) do
      {:ok, temp} ->
        news_stats = update_stats(stats, location)
        {:reply, "#{temp}°C", news_stats}
      _ ->
        {:reply, :error, stats}
    end
  end

  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end

  def handle_cast(:reset_stats, _stats) do
    {:noreply, %{}}
  end

  def handle_cast(:stop, stats) do
    {:stop, :normal, :ok, stats}
  end

  def terminate(reason, stats) do
    IO.puts "server terminated because of #{inspect reason}"
    inspect stats
    :ok
  end

  def handle_info(msg, stats) do
    IO.puts "received #{inspect msg}"
    {:noreply, stats}
  end

  ## Helper Functions
  defp temperature_of(location) do
    location |> url_for |> HTTPoison.get |> parse_response
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode! |> compute_temperature
  end

  defp parse_response(_) do
    IO.puts("parse_response")
    :error
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp update_stats(old_stats, location) do
    case Map.has_key?(old_stats, location) do
      true ->
        Map.update!(old_stats, location, &(&1 + 1))
      false ->
        Map.put_new(old_stats, location, 1)
    end
  end

  defp apikey do
    "aef86c3e40aee07c60a3b207e74c5a7b"
  end
end
