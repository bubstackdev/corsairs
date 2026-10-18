module {
  coreai.graph @main(%arg0: tensor<2x3xsi16> {coreai.name = "x"}) -> (tensor<2x3xsi16> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<2x3xsi16>, tensor<2x3xsi16>) -> tensor<2x3xsi16>
    coreai.output %0 : tensor<2x3xsi16>
  }
}

