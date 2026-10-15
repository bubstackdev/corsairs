module {
  coreai.graph @main(%arg0: tensor<1xf32> {coreai.name = "x"}) -> (tensor<536870913xf32> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.constant dense<536870913> : tensor<1xui32>
    %1 = coreai.constant dense<0> : tensor<1xsi32>
    %2 = coreai.broadcast_in_dims %arg0, %0, %1 : (tensor<1xf32>, tensor<1xui32>, tensor<1xsi32>) -> tensor<536870913xf32>
    coreai.output %2 : tensor<536870913xf32>
  }
}

