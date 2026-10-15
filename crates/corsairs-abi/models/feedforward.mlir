module {
  coreai.graph @main(%arg0: tensor<2x3xf32> {coreai.name = "x"}) -> (tensor<2x2xf32> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.constant dense<[[1.000000e+00, 2.000000e+00], [-1.000000e+00, 0.000000e+00], [2.000000e+00, -1.000000e+00], [0.000000e+00, 1.000000e+00]]> : tensor<4x2xf32>
    %1 = coreai.constant dense<[1.000000e+00, -2.000000e+00, 0.000000e+00, 3.000000e+00]> : tensor<4xf32>
    %2 = coreai.constant dense<[[1.000000e+00, -1.000000e+00, 2.000000e+00, 0.000000e+00], [0.000000e+00, 2.000000e+00, 1.000000e+00, -1.000000e+00], [-1.000000e+00, 0.000000e+00, 1.000000e+00, 1.000000e+00]]> : tensor<3x4xf32>
    %3 = coreai.batch_matmul %arg0, %2 : (tensor<2x3xf32>, tensor<3x4xf32>) -> tensor<2x4xf32>
    %4 = coreai.decomposable.broadcasting_add %3, %1 : (tensor<2x4xf32>, tensor<4xf32>) -> tensor<2x4xf32>
    %5 = coreai.relu %4 : (tensor<2x4xf32>) -> tensor<2x4xf32>
    %6 = coreai.batch_matmul %5, %0 : (tensor<2x4xf32>, tensor<4x2xf32>) -> tensor<2x2xf32>
    coreai.output %6 : tensor<2x2xf32>
  }
}

