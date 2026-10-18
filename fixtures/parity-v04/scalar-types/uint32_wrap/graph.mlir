module {
  coreai.graph @main(%arg0: tensor<2x3xui32> {coreai.name = "x"}) -> (tensor<2x3xui32> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<2x3xui32>, tensor<2x3xui32>) -> tensor<2x3xui32>
    coreai.output %0 : tensor<2x3xui32>
  }
}

