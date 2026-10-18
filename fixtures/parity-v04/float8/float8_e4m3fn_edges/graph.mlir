module {
  coreai.graph @main(%arg0: tensor<2x3xf8E4M3FN> {coreai.name = "x"}) -> (tensor<2x3xf8E4M3FN> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<2x3xf8E4M3FN>, tensor<2x3xf8E4M3FN>) -> tensor<2x3xf8E4M3FN>
    coreai.output %0 : tensor<2x3xf8E4M3FN>
  }
}

