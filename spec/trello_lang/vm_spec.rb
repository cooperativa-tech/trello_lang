RSpec.describe TrelloLang::VM do
  it "increments the data pointer" do
    vm = TrelloLang::VM.new(">")

    vm.run

    dp = vm.instance_variable_get(:@dp)
    expect(dp).to eq(1)
  end

  it "decrements the data pointer" do
    vm = TrelloLang::VM.new("<")
    vm.instance_variable_set(:@dp, 2)

    vm.run

    dp = vm.instance_variable_get(:@dp)
    expect(dp).to eq(1)
  end

  it "has a minimum of zero for the data pointer" do
    vm = TrelloLang::VM.new("<")

    vm.run

    dp = vm.instance_variable_get(:@dp)
    expect(dp).to eq(0)
  end

  it "increments the instruction pointer on every instruction" do
    vm = TrelloLang::VM.new("><")

    vm.run

    ip = vm.instance_variable_get(:@ip)
    expect(ip).to eq(2)
  end

  it "increments the current byte" do
    vm = TrelloLang::VM.new("+")

    vm.run

    mem = vm.instance_variable_get(:@mem)
    expect(mem.first).to eq(1)
  end

  it "decrements the current byte" do
    vm = TrelloLang::VM.new("-")
    vm.instance_variable_set(:@mem, [2])

    vm.run

    mem = vm.instance_variable_get(:@mem)
    expect(mem.first).to eq(1)
  end

  it "prints the current buffer" do
    mem = [1, 2, 3]
    vm = TrelloLang::VM.new(".")
    vm.instance_variable_set(:@mem, mem)
    vm.instance_variable_set(:@dp, 3)
    allow(vm).to receive(:puts)

    vm.run

    expect(vm).to have_received(:puts).with(mem)
  end

  it "reads from the stdin and writes to memory" do
    allow(STDIN).to receive(:getch)
    vm = TrelloLang::VM.new(",")

    vm.run

    expect(STDIN).to have_received(:getch)
  end

  it "sets the call stack correctly when looping" do
    vm = TrelloLang::VM.new("[")
    vm.instance_variable_set(:@mem, [1, 2, 3])

    vm.run

    call_stack = vm.instance_variable_get(:@call_stack)
    expect(call_stack).to eq([0])
  end

  it "correctly fast forwards on loop false conditions" do
    vm = TrelloLang::VM.new("[>++")
    vm.instance_variable_set(:@mem, [0, 1])

    vm.run

    mem = vm.instance_variable_get(:@mem)
    ff = vm.instance_variable_get(:@ff)
    expect(mem).to eq([0, 1])
    expect(ff).to be
  end

  it "pops the call stack on loop close" do
    vm = TrelloLang::VM.new("]")
    vm.instance_variable_set(:@call_stack, [1, 2])
    vm.instance_variable_set(:@ff, 1)

    vm.run

    call_stack = vm.instance_variable_get(:@call_stack)
    expect(call_stack).to eq([1])
  end

  it "sets the instruction pointer on loop jumps" do
    vm = TrelloLang::VM.new("]")
    vm.instance_variable_set(:@call_stack, [10, 20])

    vm.run

    ip = vm.instance_variable_get(:@ip)
    expect(ip).to eq(20)
  end
end
