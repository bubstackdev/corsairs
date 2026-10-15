module {
  coreai.graph @main(%arg0: tensor<0x3xf32> {coreai.name = "x"}) -> (tensor<0x3xf32> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<0x3xf32>, tensor<0x3xf32>) -> tensor<0x3xf32>
    coreai.output %0 : tensor<0x3xf32>
  }
}

