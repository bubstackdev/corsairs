module {
  coreai.graph @main(%arg0: tensor<2x3xf32> {coreai.name = "x"}) -> (tensor<2x1xf32> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.constant dense<1> : tensor<1xsi32>
    %1 = coreai.reduce_sum %arg0, %0 : (tensor<2x3xf32>, tensor<1xsi32>) -> tensor<2x1xf32>
    coreai.output %1 : tensor<2x1xf32>
  }
}

