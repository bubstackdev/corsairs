module {
  coreai.graph @main(%arg0: tensor<0x3xui64> {coreai.name = "x"}) -> (tensor<0x3xui64> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<0x3xui64>, tensor<0x3xui64>) -> tensor<0x3xui64>
    coreai.output %0 : tensor<0x3xui64>
  }
}

