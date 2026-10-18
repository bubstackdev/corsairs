module {
  coreai.graph @main(%arg0: tensor<f64> {coreai.name = "x"}) -> (tensor<f64> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<f64>, tensor<f64>) -> tensor<f64>
    coreai.output %0 : tensor<f64>
  }
}

