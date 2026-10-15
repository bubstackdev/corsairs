module {
  coreai.graph @main(%arg0: tensor<2x3xf32> {coreai.name = "x"}) -> (tensor<2x2xf32> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.constant dense<[[2, 0], [1, 2]]> : tensor<2x2xsi32>
    %1 = coreai.constant dense<1> : tensor<si32>
    %2 = coreai.gather_along_axis %arg0 at %0 along %1 : (tensor<2x3xf32>, tensor<2x2xsi32>, tensor<si32>) to tensor<2x2xf32>
    coreai.output %2 : tensor<2x2xf32>
  }
}

