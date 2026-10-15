module {
  coreai.graph @main(%arg0: tensor<f32> {coreai.name = "x"}) -> (tensor<f32> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<f32>, tensor<f32>) -> tensor<f32>
    coreai.output %0 : tensor<f32>
  }
}

