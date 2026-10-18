module {
  coreai.graph @main(%arg0: tensor<f8E5M2> {coreai.name = "x"}) -> (tensor<f8E5M2> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<f8E5M2>, tensor<f8E5M2>) -> tensor<f8E5M2>
    coreai.output %0 : tensor<f8E5M2>
  }
}

