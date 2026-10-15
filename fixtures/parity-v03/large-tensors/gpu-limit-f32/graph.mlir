module {
  coreai.graph @main(%arg0: tensor<536870912xf32> {coreai.name = "x"}) -> (tensor<536870912xf32> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<536870912xf32>, tensor<536870912xf32>) -> tensor<536870912xf32>
    coreai.output %0 : tensor<536870912xf32>
  }
}

