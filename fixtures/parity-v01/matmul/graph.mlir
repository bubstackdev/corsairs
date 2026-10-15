module {
  coreai.graph @main(%arg0: tensor<2x3xf32> {coreai.name = "x"}) -> (tensor<2x2xf32> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.constant dense<[[1.000000e+00, 2.000000e+00], [3.000000e+00, -1.000000e+00], [2.000000e+00, 0.000000e+00]]> : tensor<3x2xf32>
    %1 = coreai.batch_matmul %arg0, %0 : (tensor<2x3xf32>, tensor<3x2xf32>) -> tensor<2x2xf32>
    coreai.output %1 : tensor<2x2xf32>
  }
}

