module {
  coreai.graph @main(%arg0: tensor<2x3xui8> {coreai.name = "x"}) -> (tensor<3x2xui8> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.constant dense<[1, 0]> : tensor<2xui32>
    %1 = coreai.transpose %arg0, %0 : (tensor<2x3xui8>, tensor<2xui32>) -> tensor<3x2xui8>
    coreai.output %1 : tensor<3x2xui8>
  }
}

