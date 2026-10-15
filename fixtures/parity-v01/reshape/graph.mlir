module {
  coreai.graph @main(%arg0: tensor<2x3xf32> {coreai.name = "x"}) -> (tensor<3x2xf32> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.constant dense<[3, 2]> : tensor<2xui32>
    %1 = coreai.reshape %arg0, %0 : (tensor<2x3xf32>, tensor<2xui32>) -> tensor<3x2xf32>
    coreai.output %1 : tensor<3x2xf32>
  }
}

