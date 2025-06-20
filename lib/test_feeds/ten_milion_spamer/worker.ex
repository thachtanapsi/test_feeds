defmodule TenMilionSpamer.Worker do
  use GenServer

  # localhost
  @target_ip {10.161, 53, 15}
  @target_port 5_000

  def start_link(id: id, name: name) do
    GenServer.start_link(__MODULE__, [id: id, name: name], name: name)
  end

  def init(id: id, name: _name) do
    IO.puts("Worker #{id} started")
    {:ok, %{message: []}}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:do_attack, %{message: []}) do
    {:noreply, %{message: []}}
  end

  def handle_info(:do_attack, %{message: [weapon | new_state]} = state) do
    # call udp
    UdpSender.send_udp(weapon, @target_ip, @target_port)
    # continute attack per milisecond
    Process.send_after(self(), :do_attack, 3000)
    {:noreply, state |> Map.update(:message, [], fn _current -> new_state end)}
  end

  def handle_cast({:store_message, message}, state) do
    {:noreply, state |> Map.update(:message, [], fn current -> [message | current] end)}
  end

  def handle_cast(:attack, state) do
    Process.send(self(), :do_attack, [])
    {:noreply, state}
  end

  def handle_cast(:revert, state) do
    {:noreply, state |> Map.update(:message, [], fn current -> Enum.reverse(current) end)}
  end

  @doc """
    TenMilionSpamer.Worker.state(:"TenMilionSpamer.Worker_1")
  """
  def state(id) do
    GenServer.call(id, :state)
  end
end
