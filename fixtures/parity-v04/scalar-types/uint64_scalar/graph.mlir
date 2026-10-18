module {
  coreai.graph @main(%arg0: tensor<ui64> {coreai.name = "x"}) -> (tensor<ui64> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<ui64>, tensor<ui64>) -> tensor<ui64>
    coreai.output %0 : tensor<ui64>
  }
}

