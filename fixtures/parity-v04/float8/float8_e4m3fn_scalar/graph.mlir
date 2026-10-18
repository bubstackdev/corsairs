module {
  coreai.graph @main(%arg0: tensor<f8E4M3FN> {coreai.name = "x"}) -> (tensor<f8E4M3FN> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<f8E4M3FN>, tensor<f8E4M3FN>) -> tensor<f8E4M3FN>
    coreai.output %0 : tensor<f8E4M3FN>
  }
}

