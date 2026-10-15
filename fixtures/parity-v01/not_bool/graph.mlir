module {
  coreai.graph @main(%arg0: tensor<2x3xi1> {coreai.name = "x"}) -> (tensor<2x3xi1> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.not %arg0 : tensor<2x3xi1> -> tensor<2x3xi1>
    coreai.output %0 : tensor<2x3xi1>
  }
}

