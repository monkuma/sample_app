class HelloController < ApplicationController
  def index
  end

  def hello
    render html: "hello, world..."
  end
end
