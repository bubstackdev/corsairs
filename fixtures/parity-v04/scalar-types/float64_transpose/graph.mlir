module {
  coreai.graph @main(%arg0: tensor<2x3xf64> {coreai.name = "x"}) -> (tensor<3x2xf64> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.constant dense<[1, 0]> : tensor<2xui32>
    %1 = coreai.transpose %arg0, %0 : (tensor<2x3xf64>, tensor<2xui32>) -> tensor<3x2xf64>
    coreai.output %1 : tensor<3x2xf64>
  }
}

