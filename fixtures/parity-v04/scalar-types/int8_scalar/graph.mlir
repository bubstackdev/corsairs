module {
  coreai.graph @main(%arg0: tensor<si8> {coreai.name = "x"}) -> (tensor<si8> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<si8>, tensor<si8>) -> tensor<si8>
    coreai.output %0 : tensor<si8>
  }
}

