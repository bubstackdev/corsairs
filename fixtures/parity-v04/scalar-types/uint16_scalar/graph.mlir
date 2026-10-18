module {
  coreai.graph @main(%arg0: tensor<ui16> {coreai.name = "x"}) -> (tensor<ui16> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<ui16>, tensor<ui16>) -> tensor<ui16>
    coreai.output %0 : tensor<ui16>
  }
}

