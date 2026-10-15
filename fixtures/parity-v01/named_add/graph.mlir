module {
  coreai.graph @main(%arg0: tensor<2x3xf32> {coreai.name = "x"}, %arg1: tensor<2x3xf32> {coreai.name = "addend"}) -> (tensor<2x3xf32> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg1 : (tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<2x3xf32>
    coreai.output %0 : tensor<2x3xf32>
  }
}

