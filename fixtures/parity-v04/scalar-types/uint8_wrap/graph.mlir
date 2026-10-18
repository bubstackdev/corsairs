module {
  coreai.graph @main(%arg0: tensor<2x3xui8> {coreai.name = "x"}) -> (tensor<2x3xui8> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<2x3xui8>, tensor<2x3xui8>) -> tensor<2x3xui8>
    coreai.output %0 : tensor<2x3xui8>
  }
}

