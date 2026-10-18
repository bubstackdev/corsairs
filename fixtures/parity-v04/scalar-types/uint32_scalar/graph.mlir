module {
  coreai.graph @main(%arg0: tensor<ui32> {coreai.name = "x"}) -> (tensor<ui32> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<ui32>, tensor<ui32>) -> tensor<ui32>
    coreai.output %0 : tensor<ui32>
  }
}

